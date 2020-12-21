import csv
import os

script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
inFilename = input("Enter CSV file name for UCR: ")
outFilename = "UCR.sql"
tableName = "UCR"
tableCreation = "DROP TABLE UCR;\n" + "CREATE TABLE UCR(\n\tORI VARCHAR(7)," + \
                "\n\tcityName VARCHAR(30),\n\tYear INTEGER,\n\tNumMurders INTEGER," + \
                "\n\tNumSolved INTEGER,\n\tstate VARCHAR(20),\n\tcounty VARCHAR(50)," + \
                "\n\tAgency VARCHAR(50),\n\tprimary key(ORI, Year, state)\n);\n"
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
                if 1 < attributeCount < 5:
                    line += attribute + ", "
                else:
                    attribute = attribute.translate({ord(c): None for c in '\''})
                    line += "'" + attribute + "', "
                attributeCount += 1
            pline = line[:len(line) - 2]
            pline += ");"
            f.write(f'{pline}\n')
            line_count += 1
    print(f'Processed {line_count} lines.')

csv_file.close()
f.close()
