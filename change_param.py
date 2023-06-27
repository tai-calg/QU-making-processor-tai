import subprocess
import re
import sys

def modify_file(file_path, line_num, old_str, new_str):
    with open(file_path, 'r') as file:
        lines = file.readlines()
        
    line = lines[line_num - 1]
    lines[line_num - 1] = line.replace(old_str, new_str)

    with open(file_path, 'w') as file:
        file.writelines(lines)

def run_command(cmd):
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    return output.decode('utf-8'), error

def save_to_file(filename, data):
    with open(filename, 'a') as file:
        file.write(data)

def main(value):
    value_half = str(value / 2)
    modify_file('test/top_test.v', 7, '= 10', '= ' + str(value))
    modify_file('test/top_test.v', 8, '=  5', '=  ' + value_half)
    modify_file('first_test.tcl', 47, '-period 10.00', '-period ' + str(value) + '.00')

    cmd1 = 'dc_shell-t -f first_test.tcl | tee log'
    cmd2 = ' grep "Total Dynamic Power" log'
    cmd3 = ' grep "Total cell area" log'
    cmd4 = ' grep -m 1 "data arrival time" log '

    run_command(cmd1)
    power_output, power_error = run_command(cmd2)
    area_output, area_error = run_command(cmd3)
    time_output, time_error = run_command(cmd4)

    save_to_file(f'mlt_log_csv.txt', str(value) + ',' + power_output + ',' + area_output+ ',' + time_output + '\n')
    


if __name__ == "__main__":
    # for i = 8.0, 8.1 , ... , 10.0
    for i in range(80, 101):
        i /= 10.0
        print("value = ", i)
        main(i)
    # main(7)

# if __name__ == "__main__":
    # if len(sys.argv) != 2:
    #     print("Usage: python change_param.py <value>")
    # else:
    #     main(float(sys.argv[1]))