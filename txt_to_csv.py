import csv
import re

def parse_line(line):
    return re.findall(r"[-+]?\d*\.\d+|\d+", line)

with open('mlt_log_csv.txt', 'r') as f, open('mlt_log_csv_out.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["clock", "power", "cell area", "arrival time"])
    lines = f.readlines()
    for i in range(0, len(lines), 4):
        clock = parse_line(lines[i])
        power = parse_line(lines[i])
        cell_area = parse_line(lines[i+1])
        arrival_time = parse_line(lines[i+2])
        writer.writerow([clock, power, cell_area, arrival_time])
