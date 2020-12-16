import csv
import os
import re

script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
inFilename = input("Enter CSV file name for SKR: ")
outFilename = "SKD.sql"
tableName = "SKD"
tableCreation = "DROP TABLE SKD;\n" + "CREATE TABLE SKD(\n\tName VARCHAR(30) primary key," + \
                "\n\tYearStarted INTEGER,\n\tYearEnded INTEGER,\n\tProvenVictims INTEGER," + \
                "\n\tPossibleVictims INTEGER,\n\tStatus VARCHAR(100),\n\tNotes VARCHAR(500)\n);\n"
script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
rel_path = "sql_outputs/" + outFilename
abs_file_path = os.path.join(script_dir, rel_path)
f = open(abs_file_path, "w")

rel_path = "csv_sources/" + inFilename
abs_file_path = os.path.join(script_dir, rel_path)

with open(abs_file_path, mode='r') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    f.write(tableCreation)
    f.write("\n")
    for row in csv_reader:
        if line_count == 0:
            print(f'Column names are {", ".join(row)}')
            line_count += 1
        else:
            line = "INSERT INTO " + tableName + " VALUES ("
            attributeCount = 0
            for attribute in row:
                if attributeCount == 1:
                    line += attribute[:4] + ", " + attribute[5:] + ", "
                elif attributeCount == 2:
                    line += attribute + ", "
                else:
                    line += "'" + attribute + "', "
                attributeCount += 1
            pline = line[:len(line) - 2]
            pline += ");"
            f.write(f'{pline}\n')
            line_count += 1
    print(f'Processed {line_count} lines.')

csv_file.close()
f.close()
