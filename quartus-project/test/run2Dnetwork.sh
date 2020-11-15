BASE=0xc0020000

sudo echo "Got sudo permissions temporarily"


##################
# Register space #
##################

# Input vector
a=$(($BASE + 0)) 
b=$(($BASE + 4)) 

# Output vector
c=$(($BASE + 8)) 


#########################################
# Functions to read/write from /dev/mem #
#########################################

write_register () {
	sudo ./devmem ${!1} 32 $2 > /dev/null
}

read_register () {
	sudo ./devmem ${!1} 32
}

reset_write_read_register () {
	echo "Writing 0x00 to $1"
	write_register $1 0x00
	echo "Writing $2 to $1"
	write_register $1 $2
	val=$(read_register $1)
	echo "Reading $1: $val"
}


###########################
# Perform the calculation #
###########################

# The network can be found at
# https://github.com/ryanorendorff/sbtb-2020-type-safe-fpga/blob/main/ip/RunNetwork.hs

# We are going to ping all 4 quadrants

pos_x=0x03000000 #  1.5
neg_x=0xfd000000 # -1.5 
pos_y=0x05000000 #  2.5
neg_y=0xfb000000 # -2.5

pos_1=0x02000000
neg_1=0xfe000000

# Quadrant 1

echo ""
echo "Quadrant 1"
echo "++++++++++"

# Values are SFixed 7 25 values
# Send 1.5 to register a
echo ""
reset_write_read_register "a" pos_x
echo ""
echo "--------------"
echo ""

# Send 2.5 to register b
reset_write_read_register "b" pos_y
echo ""
echo "--------------"
echo ""

echo "Reading result"
echo "=============="

# Expect 1.0
c_val=$(read_register "c")
echo "Actual output:   $c_val"
echo "Expected output: $pos_1"
echo ""


# Quadrant 2

echo "Quadrant 2"
echo "++++++++++"

# Values are SFixed 7 25 values
# Send -1.5 to register a
echo ""
reset_write_read_register "a" $neg_x
echo ""
echo "--------------"
echo ""

# Send 2.5 to register b
reset_write_read_register "b" $pos_y
echo ""
echo "--------------"
echo ""

echo "Reading result"
echo "=============="

# Expect -1.0
c_val=$(read_register "c")
echo "Actual output:   $c_val"
echo "Expected output: $neg_1"
echo ""


# Quadrant 3

echo "Quadrant 3"
echo "++++++++++"

# Values are SFixed 7 25 values
# Send -1.5 to register a
echo ""
reset_write_read_register "a" $neg_x
echo ""
echo "--------------"
echo ""

# Send -2.5 to register b
reset_write_read_register "b" $neg_y
echo ""
echo "--------------"
echo ""

echo "Reading result"
echo "=============="

# Expect 1.0
c_val=$(read_register "c")
echo "Actual output:   $c_val"
echo "Expected output: $pos_1"
echo ""


# Quadrant 4

echo "Quadrant 4"
echo "++++++++++"

# Values are SFixed 7 25 values
# Send 1.5 to register a
echo ""
reset_write_read_register "a" $pos_x
echo ""
echo "--------------"
echo ""

# Send -2.5 to register b
reset_write_read_register "b" $neg_y
echo ""
echo "--------------"
echo ""

echo "Reading result"
echo "=============="

# Expect -1.0
c_val=$(read_register "c")
echo "Actual output:   $c_val"
echo "Expected output: $neg_1"
echo ""
