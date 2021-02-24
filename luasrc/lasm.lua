local argc, argv = getargs()
local content = fopen(argv)
content = string.split(content, " ")
for i = 1,#content do
print(content[i])
end