import csv
import os

script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
inFilename = input("Enter CSV file name for SHR: ")
outFilename = "SHR.sql"
tableName = "SHR"
tableCreation = "DROP TABLE SHR;\n" + "CREATE TABLE SHR(\n\tID VARCHAR(16) primary key," + \
                "\n\tCity VARCHAR(30),\n\tORI VARCHAR(7),\n\tState VARCHAR(20),\n\tAgency VARCHAR(50)," + \
                "\n\tAgentType VARCHAR(50),\n\tSource VARCHAR(10),\n\tSolved VARCHAR(3),\n\tYear INTEGER," + \
                "\n\tMonth VARCHAR(10),\n\tHomicide VARCHAR(100),\n\tSituation VARCHAR(100),\n\tVictimAge INTEGER," + \
                "\n\tVictimSex VARCHAR(6),\n\tVictimRace VARCHAR(20),\n\tVictimEthnicity VARCHAR(20)," + \
                "\n\tOffenderAge INTEGER,\n\tOffenderSex VARCHAR(6),\n\tOffenderRace VARCHAR(20)," + \
                "\n\tOffenderEthnicity VARCHAR(20),\n\tWeapon VARCHAR(20),\n\tRelationship VARCHAR(20)," + \
                "\n\tCircumstance VARCHAR(150)\n);\n"
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
                if attributeCount == 9 or 10 < attributeCount < 13 or attributeCount > 25:
                    pass
                elif attributeCount == 1:
                    temp = attribute.split(", ")
                    attribute = temp[0]
                    line += "'" + attribute + "', "
                elif attributeCount == 8 or attributeCount == 15 or attributeCount == 19:
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
