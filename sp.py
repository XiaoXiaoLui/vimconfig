#!/usr/bin/python

import re
import sys
import json
import os


#PAT_FUN_START   = re.compile(r'''(?:(?:virtual|static|inline|const)*\s+[a-z_A-Z][:\w]*(?:&|\*)?\s+(?:&|\*)?\s+)?(?P<fname>(?:[a-z_A-Z]\w*::)*(?:~)?[a-z_A-Z]\w*)\([^;\][(){}=+\-'"]*\)\s*(?:const)?\s*\{''', re.M)
PAT_FUN_START   = re.compile(r'''(?P<fname>(?:[a-z_A-Z]\w*::)*(?:~)?[a-z_A-Z]\w*)\([^;\][(){}=+\-'"]*\)(?:(?:\s+const|\s+override\s+)*|(?::[^{};]*)?\s+)\{''', re.M)
PAT_CLASS_START = re.compile(r'''(?:class|struct)\s+(?P<cname>\w+)'''     # class ClassName
                             r'''(?:\s*:\s*(?:public|protected|private)\s+[\w:]+\s*(?:,\s*(?:public|protected|private)\s+[\w:]+\s*)*)?'''  # inheritance list
                             r'''\s*\{''', re.M)
PAT_GREP_RES = re.compile(r'^(?P<filepath>[\w./\-_]+):(?P<linenum>\d+):', re.M)
PAT_FILENAME_WITH_INDEX = re.compile(r'^(?P<filename>[\w.\-_]+)\[(?P<index>\d+)\]', re.M)

CPP_EXTS = ('.cpp', '.cc', '.c', '.h', '.hpp')
IGNORE_DIRS = ('.svn', '.git')


class ScopeInfo:
    def __init__(self, start, end, name, scope_type):
        self.start = start
        self.end = end
        self.name = name
        self.type = scope_type


def findnth(s1, s2, n):
    if n == 0:
        return 0

    idx = s1.find(s2)
    while n > 1 and idx >= 0:
        idx = s1.find(s2, idx + len(s2))
        n -= 1

    return idx

def is_cpp_file(filepath):
    if filepath.endswith(CPP_EXTS):
        return True
    return False

class CppFile:
    def __init__(self, file_path):
        self.file_path = file_path
        self.scope_info = []
        self.preprocessed = False

    def preprocess_file_content(self):
        if self.preprocessed:
            return

        file = open(self.file_path, 'r')
        self.code = file.read()
        self.line_start_pos = [0]

        pos = self.code.find('\n')
        while pos >= 0:
            self.line_start_pos.append(pos + 1)
            pos = self.code.find('\n', pos + 1)

        self.delete_comment()
        self.preprocessed = True

    def get_line_num(self, pos):
        left = 0
        right = len(self.line_start_pos)

        while right - left > 1:
            mid = (left + right) // 2
            if self.line_start_pos[mid] <= pos:
                left = mid
            else:
                right = mid
        return right

    def delete_comment(self):
        i = 0
        code = list(self.code)
        need_delete_quoted_str = is_cpp_file(self.file_path)
        try:
            while i < len(self.code):
                if code[i] == '/' and code[i + 1] == '/':
                    last_i = i
                    i += 2
                    while i < len(code) and code[i] != '\n':
                        code[i] = ' '
                        i += 1
                elif code[i] == '/' and code[i + 1] == '*':
                    last_i = i
                    i += 2
                    while code[i] != '*' or code[i + 1] != '/':
                        if code[i] != '\n':
                            code[i] = ' '
                        i += 1
                elif need_delete_quoted_str and code[i] == '"' and code[i - 1] != '\\' and code[i - 1] != 'R':
                    last_i = i
                    i += 1
                    while code[i] != '"':
                        if code[i] == '\\':
                            if code[i + 1] != '\n':
                                code[i + 1] = ' '
                            i += 2
                        else:
                            if code[i] != '\n':
                                code[i] = ' '
                            i += 1
                elif need_delete_quoted_str and code[i] == '"' and code[i - 1] == 'R':
                    last_i = i
                    i += 1
                    r_start = i
                    while code[i] != '(':
                        i += 1
                    token = code[r_start:i]
                    i += 1
                    str_start = i
                    # first find the raw string end
                    while True:
                        if code[i] == '"' and code[(i - len(token)):i] == token and code[i - len(token) - 1] == ')':
                            break;
                        i += 1
                    i_tmp = i
                    str_end = i - len(token) - 1
                    i = str_start
                    while i < str_end:
                        if code[i] != '\n':
                            code[i] = ' '
                        i += 1
                    i = i_tmp
                elif need_delete_quoted_str and code[i] == "'":
                    last_i = i
                    i += 1
                    while code[i] != "'":
                        if code[i] == '\\':
                            code[i + 1] = ' '
                        i += 1
                i += 1
        except:
            print('error in delete_comment: file=%s, last_i=%d, line=%d, ch=%s, need=%d' % (self.file_path, last_i, self.get_line_num(last_i), code[last_i], int(need_delete_quoted_str)))
            print(''.join(code[(last_i - 100):(last_i + 50)]))
            #print(''.join(code))
            raise Exception('error')

        self.code = ''.join(code)

    def find_match_bracket(self, pos):
        i = pos
        stack = ['{']
        ret = -1
        try:
            while i < len(self.code):
                ch = self.code[i]
                if ch == '{':
                    stack.append('{')
                elif ch == '}':
                    stack.pop()
                    if len(stack) == 0:
                        ret = i
                        break;
                elif ch == '/' and self.code[i + 1] == '/':
                    while i < len(self.code) and self.code[i] != '\n':
                        i += 1
                elif ch == '/' and self.code[i + 1] == '*':
                    i += 3
                    while i < len(self.code) and (self.code[i] != '/' or self.code[i - 1] != '*'):
                        i += 1
                i += 1
        except:
            if i >= len(self.code):
                print('i too big')
            else:
                print('i=%d, ch=%s' % (i, code[i]))
            ret = -1
        if ret == -1:
            print("i=%d, line=%d" % (i, self.get_line_num(i)))
        return ret

    def get_scope_for_pattern(self, line_num, pat, groupname):
        linepos = findnth(self.code, '\n', line_num - 1) + 1
        linepos_end = findnth(self.code, '\n', line_num) + 1
        last_match = None
        for m in pat.finditer(self.code):
            cur_idx = m.start()
            if cur_idx > linepos_end:
                break
            last_match = m

        if not last_match:
            return ''

        # seems to be in a function
        i = last_match.end()
        idx_end = self.find_match_bracket(i)

        if idx_end < linepos:
            return ''

        return last_match.group(groupname)

    def get_scope(self, linenum):
        self.preprocess_file_content()
        s = self.get_scope_for_pattern(linenum, PAT_FUN_START, 'fname')
        if s:
            s = '<%s()>:  ' % s
        if s == '':
            s = self.get_scope_for_pattern(linenum, PAT_CLASS_START, 'cname')
            if s:
                s = '<class %s>:  ' % s
        if not s:
            s = '  '
        return s

    def gen_scope_info_for_pattern(self, pat, groupname, scope_type):
        for m in pat.finditer(self.code):
            start = m.start()
            end = self.find_match_bracket(m.end())

            if end == -1:
                print("file_path=%s,group=%s" % (self.file_path, m.group(0)))
                print('error in gen_scope_info_for_pattern: start=%d, end=%d' % (start, end))
                continue
            scope = ScopeInfo(self.get_line_num(start), self.get_line_num(end), m.group(groupname), scope_type)
            self.scope_list.append(scope)

    def gen_scope_info(self):
        self.preprocess_file_content()
        self.scope_list = []
        self.gen_scope_info_for_pattern(PAT_CLASS_START, 'cname', 'class')
        self.gen_scope_info_for_pattern(PAT_FUN_START, 'fname', 'function')

        def sortfun(scope_info):
            return scope_info.start
        self.scope_list.sort(key = sortfun)

        self.scope_info = []
        for scope in self.scope_list:
            self.insert_scope(scope, self.scope_info)


    # insert scope in scope list(lst is in json like format)
    # this algorithm assumes that scope is inserted by ascending order
    def insert_scope(self, scope, lst):
        dct = dict()
        dct['start'] = scope.start
        dct['end'] = scope.end
        dct['name'] = scope.name
        dct['type'] = scope.type
        dct['subscope'] = []

        if len(lst) == 0:
            lst.append(dct)
            return

        last_dct = lst[-1]
        if scope.start > last_dct['end']:
            lst.append(dct)
        elif scope.start > last_dct['start'] and scope.end < last_dct['end']:
            self.insert_scope(scope, last_dct['subscope'])
        else:
            print("error in CppFile.insert_scope file=%s: scope.start=%d, scope.end=%d, dict.start=%d, dict.end=%d" % (self.file_path, scope.start, scope.end, last_dct['start'], last_dct['end']))

    def get_scope_by_scope_info(self, line_num):
        def get_scope_inner(lst):
            if len(lst) == 0:
                return None

            left = 0
            right = len(lst)
            while right - left > 1:
                mid = (left + right) // 2
                if lst[mid]['end'] < line_num:
                    left = mid
                else:
                    right = mid
            if lst[left]['end'] >= line_num:
                right = left

            if right == len(lst) or lst[right]['start'] > line_num:
                return None

            scope = lst[right]
            subscope = get_scope_inner(lst[right]['subscope'])
            if subscope:
                scope = subscope
            return scope


        scope =  get_scope_inner(self.scope_info)
        if scope == None:
            return '  '
        elif scope['type'] == 'function':
            return '<%s()>:  ' % scope['name']
        elif scope['type'] == 'class':
            return '<class %s>:  ' % scope['name']
        else:
            raise Exception('unknown scope type in get_scope_by_scope_info')







def gen_scope_for_grep_res_simple(file_path, shorten_path = True):
    res = ''
    cppfile = None
    with open(file_path, 'r') as file:
        for line in file:
            m = PAT_GREP_RES.match(line)
            if not m:
                continue
            path = m.group('filepath')
            linenum = int(m.group('linenum'))
            if not cppfile or cppfile.file_path != path:
                cppfile = CppFile(path)
            scope = cppfile.get_scope(linenum)
            if shorten_path:
                path = os.path.basename(path)

            newline = path + line[m.end('filepath'):m.end()] + scope + line[m.end():]
            res += newline

    open(file_path, 'w').write(res)
    #open('/home/lvgb/tmpbuffer0.cpp', 'w').write(res)




# gen scope.json for all files in dir_path and its subdirectories
def gen_scope_info_json(dir_path):
    def gen_scope_info_inner(scope_dct, path_dct, cur_path):
        for name in os.listdir(cur_path):
            path = os.path.join(cur_path, name)
            if os.path.isfile(path) and name.endswith(CPP_EXTS):
                code = CppFile(path)
                code.gen_scope_info()
                scope_dct[path] = code.scope_info

                if name not in path_dct:
                    path_dct[name] = []
                path_dct[name].append(path)
            elif os.path.isdir(path) and name not in IGNORE_DIRS:
                gen_scope_info_inner(scope_dct, path_dct, path)

    scope_dct = dict()
    path_dct = dict()
    gen_scope_info_inner(scope_dct, path_dct, dir_path)
    dct = dict()
    dct['scope'] = scope_dct
    dct['path'] = path_dct

    json_path = os.path.join(dir_path, 'scope.json')
    with open(json_path, 'w') as outfile:
        json.dump(dct, outfile, indent = 4)


def gen_scope_for_grep_res_using_scope_file(grep_file, scope_file, shorten_path = True):
    with open(scope_file, 'r') as infile:
        dct = json.load(infile)
    res = ''
    cppfile = None
    with open(grep_file, 'r') as file:
        for line in file:
            m = PAT_GREP_RES.match(line)
            if not m:
                continue
            path = m.group('filepath')
            linenum = int(m.group('linenum'))
            if not cppfile or cppfile.file_path != path:
                cppfile = CppFile(path)
                cppfile.scope_info = dct['scope'][path]
            scope = cppfile.get_scope_by_scope_info(linenum)


            if shorten_path:
                name = os.path.basename(path)
                if len(dct['path'][name]) > 1:
                    idx = dct['path'][name].index(path)
                    path = '%s[%d]' % (name, idx)
                else:
                    path = os.path.basename(path)


            newline = path + line[m.end('filepath'):m.end()] + scope + line[m.end():]
            res += newline

    open(grep_file, 'w').write(res)
    #open('/home/lvgb/tmpbuffer.cpp', 'w').write(res)

def print_absolute_path(scope_file, indexed_filename):
    m = PAT_FILENAME_WITH_INDEX.match(indexed_filename)
    filename = m.group('filename')
    idx = int(m.group('index'))

    with open(scope_file, 'r') as file:
        dct = json.load(file)

    path = dct['path'][filename][idx]
    print(path)




def dm(match):
    if match is None:
        return None
    return '<Match: %r, groups=%r>' % (match.group(), match.groups())

def my_test(a):
    a = 2

def read_file(filepath):
    file = open(filepath, 'r')
    s = file.read()
    file.close()
    return s


if __name__ == '__main__':
    #print(str(sys.argv))
    command = sys.argv[1]
    if command == 'genjson':
        cwd = os.getcwd()
        gen_scope_info_json(cwd)
    elif command == 'genscope':
        method = sys.argv[2]
        if method == 'simple':
           grep_file = sys.argv[3]
           shorten_path = bool(int(sys.argv[4]))
           gen_scope_for_grep_res_simple(grep_file, shorten_path)
        elif method == 'usejson':
           grep_file = sys.argv[3]
           json_file = sys.argv[4]
           shorten_path = bool(int(sys.argv[5]))
           gen_scope_for_grep_res_using_scope_file(grep_file, json_file, shorten_path)
        else:
            raise Exception('arguemnt format error')
    elif command == 'getpath':
        json_file = sys.argv[2]
        indexed_filename = sys.argv[3]
        print_absolute_path(json_file, indexed_filename)
    else:
        raise Exception('arguemnt format error')


