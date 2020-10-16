# coding=utf-8

import sys, os, shutil

current_android_im_branch = 'androidx_4.0.3_for_flutter'
current_android_rtc_branch = 'androidx_4.0.3_for_flutter'

current_path = sys.path[0]
android_file_path = os.path.join(current_path, 'android', 'local.properties')

def change_git_branch(path, branch):
    os.chdir(path)
    result = os.popen('git branch')
    lines = result.read().split('\n')
    length = len(lines)
    current_branch = ''
    for i in range(length):
        if '*' in lines[i]:
            current_branch = lines[i]
    if current_branch != '* ' + branch:
        result = os.popen('git status')
        lines = result.read()
        if 'nothing to commit, working tree clean' in lines:
            result = os.popen('git remote update origin --prune')
            print result.read()
            result = os.popen('git checkout ' + branch)
            print result.read()
            result = os.popen('git pull --rebase')
            print result.read()
        else:
            raise RuntimeError('You need to commit your current work first! Path = ' + path + ', Branch = ' + current_branch)

def change_ios_config(remote):
    print 'change ios config remote = ' + remote

def match_android_project():
    im = os.path.join(current_path, '..', '..', 'android-imsdk')
    rtc = os.path.join(current_path, '..', '..', 'android-rtcsdk')
    change_git_branch(im, current_android_im_branch)
    change_git_branch(rtc, current_android_rtc_branch)

def change_android_config(remote):
    file = open(android_file_path, 'r')
    lines = file.readlines()
    file.close()
    des = 'rongcloud.flutter.demo.use_remote_rtc_lib=' + remote + '\n'
    need_append = 'true'
    length = len(lines)
    for i in range(length):
        if 'rongcloud.flutter.demo.use_remote_rtc_lib' in lines[i]:
            lines[i] = des
            need_append = 'false'
    if need_append == 'true':
        lines.append('\n' + des)
    file = open(android_file_path, 'w')
    file.writelines(lines)
    file.close()

def pre_build_ios():
    change_ios_config('false')

def pre_build_android():
    match_android_project()
    change_android_config('false')

def pre_build_standard():
    change_ios_config('true')
    change_android_config('true')

if 'ios-sealdev' in current_path:
    pre_build_ios()
elif 'android-sealdev' in current_path:
    pre_build_android()
else:
    pre_build_standard()

