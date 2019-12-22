/* -{cl /std:c++17 /nologo %f} */

#include <iostream>
#include <filesystem>
#include <string>
#include <direct.h>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <windows.h>
#include <map>

namespace fs = std::filesystem;
using namespace std;

map<string, int> colors{
    {"cyan", 11},
    {"green", 10},
    {"red", 12},
    {"yellow", 14}
};

/* color printer, using vector of pairs to keep insertion order */
void _color_print(vector<pair<string, string>> pairs) {
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    /* get the current attributes */
    CONSOLE_SCREEN_BUFFER_INFO info;
    GetConsoleScreenBufferInfo(hConsole, &info);
    int current_attrib = info.wAttributes;
    for (auto& pair: pairs) {
        int color = pair.second == "default" ? current_attrib : colors[pair.second];
        SetConsoleTextAttribute(hConsole, color);
        cout << pair.first;
    }
    /* revert the colors */
    SetConsoleTextAttribute(hConsole, current_attrib);
    cout << endl;
}

/* trim string */
string _trim(const std::string &s)
{
	auto start = s.begin();
	while (start != s.end() && std::isspace(*start)) {
		start++;
	}
	auto end = s.end();
	do {
		end--;
	} while (std::distance(start, end) > 0 && std::isspace(*end));

	return string(start, end + 1);
}

/* split string by char */
vector<string> _split(string &s, char c) {
    vector<string> v;
    string::size_type i = 0;
    string::size_type j = s.find(c);
    if (j == string::npos) {
        v.push_back(s);
        return v;
    }
    do {
        v.push_back(s.substr(i, j-i));
        i = ++j;
        j = s.find(c, j);
    } while (j != string::npos);
    v.push_back(s.substr(i, s.length()));
    return v;
}

string _replace(string base, const string& from, const string& to) {
    size_t start_pos = 0;
    while((start_pos = base.find(from, start_pos)) != std::string::npos) {
        base.replace(start_pos, from.length(), to);
        start_pos += to.length(); // Handles case where 'to' is a substring of 'from'
    }
    return base;
}

string _find_delimited(string base, string begin, string end) {
    /* start and end indices */
    int b_ind = base.find(begin) + begin.length();
    int e_ind = base.find(end, b_ind);
    int len = e_ind - b_ind;
    return base.substr(b_ind, len);
}

int _exec_cmd(string cmd) {
    int first_space = cmd.find(" ");
    /* get executable name to color it differently */
    string executable = cmd.substr(0, first_space);
    string args = cmd.substr(first_space, string::npos);
    _color_print({{"$ ", "cyan"}, {executable, "yellow"}, {args, "default"}});
    /* return the exit code */
    return system(cmd.c_str());
}

/* the generic handler that reads the commands from the first line */
int generic(string line_1, string filename, string namepart) {
    /* split into individual commands */
    vector<string> commands = _split(_find_delimited(line_1, "-{", "}"), '|');
    /* assume success */
    int returncode = 0;
    for (int i = 0; i < commands.size(); i++) {
        string command = _trim(commands[i]);
        /* replace file name placeholders */
        command = _replace(command, "%f", filename);
        command = _replace(command, "%n", namepart);
        /* execute commands */
        returncode = _exec_cmd(command);
        if (returncode != 0) break;
    }
    return returncode;
}

/* python handler */
int python(string line_1, string filename) {
    string args;
    if (line_1.find("-(") != string::npos) {
        args = _find_delimited(line_1, "-(", ")");
    } else {
        args = "";
    }
    string command;
    if (line_1.find(" -ip") != string::npos || line_1.find(" -ipy") != string::npos) {
        command = "ipython -i " + filename + " " + args;
    } else if (line_1.find(" -i") != string::npos) {
        command = "python -i " + filename + " " + args;
    } else {
        command = "python " + filename;
    }
    return _exec_cmd(command);
}

/* latex handler */
int latex(string line_1, string filename, string namepart, string dirname) {
    /* select the engine */
    string engine = "pdflatex";
    if (line_1.find(" -lua") != string::npos) {
        engine = "lualatex";
    } else if (line_1.find(" -xe") != string::npos) {
        engine = "xelatex";
    }
    /* create temp dir */
    fs::path temp = getenv("TMP");
    temp /= ".latexTmp";
    string temp_folder = temp.string();
    fs::create_directory(temp_folder);
    /* create the command */
    string shell_escape = line_1.find(" se") == string::npos ? "" : "--shell_escape ";
    string args = " -output-directory=" + temp_folder + " " + shell_escape + namepart;
    string typeset_cmd = engine + args;
    /* test the first run */
    int first = _exec_cmd(engine + " -interaction=nonstopmode" + args);
    if (first != 0) {
        return first;
    }
    /* additional ops */
    string version = "alpha";
    if (line_1.find(" -rel") != string::npos) {
        version = "release";
        _chdir(temp_folder.c_str());
        vector<string> bib_files;
        for(auto& file: fs::directory_iterator(dirname)) {
            fs::path p = file.path();
            if (p.extension() == ".bib") {
                fs::copy_file(p, p.filename().string(), fs::copy_options::overwrite_existing);
            }
        }
        _exec_cmd(string("bibtex ") + namepart);
        _chdir(dirname.c_str());
        _exec_cmd(typeset_cmd);
        _exec_cmd(typeset_cmd);
    } else if (line_1.find(" -beta") != string::npos) {
        version = "beta";
        _exec_cmd(typeset_cmd);
    }
    /* prepare new name with timestamp */
    time_t t = time(nullptr);
    char mbstr[100];
    strftime(mbstr, sizeof(mbstr), "%Y%m%d%a", localtime(&t));
    string formatted_time = mbstr;
    string new_name = namepart + "-" + formatted_time + "-" + version + ".pdf";
    /* delete the previous pdfs */
    for(auto& file: fs::directory_iterator(dirname.length() ? dirname : ".")) {
        fs::path p = file.path();
        string file_beginning = p.stem().string().substr(0, namepart.length() + 1);
        if (p.extension() == ".pdf" && file_beginning == namepart + "-" && p.stem() != new_name) {
                fs::remove(p);
        }
    }
    /* move the output pdf here and rename */
    fs::path old_name = temp / (namepart + string(".pdf"));
    fs::rename(old_name, new_name);
    /* open the pdf */
    _exec_cmd(string("start ") + new_name);
    return 0;
}

/* js handler */
int javascript(string line_1, string filename) {
    string command;
    if (line_1.find(" -i") != string::npos) {
        command = "node -i " + filename;
    } else {
        command = "node " + filename;
    }
    return _exec_cmd(command);
}

int main(int argc, char *argv[]) {
    if (argc == 1) {
        _color_print({{"Error: no file given", "red"}});
        return 1;
    }
    const fs::path file = argv[1];
    /* the filder location */
    string dirname = file.parent_path().string();
    /* the file name like foo.bar */
    string filename = file.filename().string();
    /* the name part like foo from foo.bar */
    string namepart = file.stem().string();
    /* the extension part */
    string extension = file.extension().string();
    /* cd to that dir */
    _chdir(dirname.c_str());
    /* read first line */
    ifstream infile(filename);
    string line_1;
    if (infile.good())
    {
      getline(infile, line_1);
    }
    infile.close();

    int returncode = 0;
    if (line_1.find("-{") != string::npos) {
        /* there are commands at the top */
        returncode = generic(line_1, filename, namepart);
    } else if (extension == ".py") {
        returncode = python(line_1, filename);
    } else if (extension == ".js") {
        returncode = javascript(line_1, filename);
    } else if (extension == ".tex") {
        returncode = latex(line_1, filename, namepart, dirname);
    } else {
        _color_print({{"No defined action", "red"}});
    }

    if (returncode == 0) {
        _color_print({{"\nCompleted without errors", "green"}});
    } else {
        _color_print({{"\nPREVIOUS COMMAND EXITED WITH ", "red"}, {to_string(returncode), "red"}});
    }
}
