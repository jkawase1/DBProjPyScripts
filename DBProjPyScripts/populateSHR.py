import csv
import os

script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
inFilename = input("Enter CSV file name for SHR: ")
outFilename = "SHR.sql"
tableName = "SHR"
tableCreation = "DROP TABLE SHR;\n" + "CREATE TABLE SHR(\n\tIDNUM INTEGER primary key,\n\tID VARCHAR(20)," + \
                "\n\tCity VARCHAR(50),\n\tORI VARCHAR(10),\n\tState VARCHAR(20),\n\tAgency VARCHAR(50)," + \
                "\n\tAgentType VARCHAR(50),\n\tSource VARCHAR(10),\n\tSolved VARCHAR(3),\n\tYear INTEGER," + \
                "\n\tMonth VARCHAR(10),\n\tHomicide VARCHAR(100),\n\tSituation VARCHAR(100),\n\tVictimAge INTEGER," + \
                "\n\tVictimSex VARCHAR(20),\n\tVictimRace VARCHAR(50),\n\tVictimEthnicity VARCHAR(50)," + \
                "\n\tOffenderAge INTEGER,\n\tOffenderSex VARCHAR(20),\n\tOffenderRace VARCHAR(50)," + \
                "\n\tOffenderEthnicity VARCHAR(50),\n\tWeapon VARCHAR(50),\n\tRelationship VARCHAR(50)," + \
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
            temp = line_count - 2
            row.insert(0, str(line_count))
            for attribute in row:
                if attributeCount == 10 or 11 < attributeCount < 14 or attributeCount > 26:
                    pass
                elif attributeCount == 2:
                    temp = attribute.split(", ")
                    attribute = temp[0]
                    attribute = attribute.translate({ord(c): None for c in '\''})
                    line += "'" + attribute + "', "
                elif attributeCount == 9 or attributeCount == 16 or attributeCount == 20:
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
