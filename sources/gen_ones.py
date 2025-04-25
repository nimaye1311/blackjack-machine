# Generate 105 rows of 75 spaced 1s per row, for a .mem file

num_rows = 105
num_cols = 75

with open("ones.mem", "w") as f:
    for _ in range(num_rows):
        row = " ".join(["1"] * num_cols)
        f.write(row + "\n")

# If you want to print to the terminal instead of writing to a file, use:
# for _ in range(num_rows):
#     print(" ".join(["1"] * num_cols))
