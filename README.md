## Description of the Program

This program, titled "String Primitives & Macros" (Proj6_emburyj.asm), is an x86 assembly project developed by Josh Embury for CS271 Section 400 at Oregon State University. The program is designed to practice low-level I/O procedures. It uses macros and procedures to prompt the user to input signed integers, validates the input value is of appropriate size and format, converts the input string to a SDWORD, and stores the integers in an array. The program procedes to display the values that the user input by converting the signed integer values to strings and printing them to the console. The sum and truncated average of the input values are displayed to the user as well. Arrays are processed and manipulated using primitive functions.

## Overview of the code

### The program is organized into the following sections:

1. Macro section: This section contains definition for two macros: mGetString and mDisplayString. They are used for prompting the user for input and displaying strings in the console.

2. Constants: The program defines constants for maximum input size (MAX_INPUT_SIZE) and the number of inputs required of the user (NUMBER_OF_INPUTS).

3. Variable definition: This section contains strings for prompts, error messages, and result messages, as well as variables and arrays used in the program, such as the input array, sum, and average.

4. Main procedure: The main procedure calls various sub-procedures to display an introduction, read input values, display the input values, find the sum, find the average, and display a farewell message.

5. Sub-procedures: The program defines a variety of sub-procedures to accomplish reading input values, writing input values, perform data validation, and calculate statistics on input values. These procedures make use of the mDisplayString macro and other functions from the Irvine32 library. For details on each sub-procedure, see docstring for each proc defined in the code.

### Here's an example of how the program works:

1. The user is prompted to enter 10 (default value for NUMBER_OF_INPUTS) signed decimal integers.
2. The program validates each input and stores it in an array.
3. Once all inputs are received, the program displays the list of entered numbers, their sum, and their truncated average.
4. The program ends with a farewell message.
Here is a sample output of the program:

        Programming Project 6: Designing low-level I/O procedures
       Author: Josh Embury
        Please provide signed integers when propted. Each number needs to be small enough to fit inside a 32 bit register. After you input the integers, I will display the list of integers you input, their sum, and their truncated average.
        Each number needs to be small enough to fit inside a 32 bit register. After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.

        Please enter an signed number: 156
        Please enter an signed number: 51d6fd
        ERROR: You did not enter an signed number or your number was too big.
        Please try again: 34
        Please enter an signed number: -186
        Please enter an signed number: 324545645323454
        ERROR: You did not enter an signed number or your number was too big.
        Please try again: -145
        Please enter an signed number: 16
        Please enter an signed number: +23
        Please enter an signed number: 51
        Please enter an signed number: 0
        Please enter an signed number: 56
        Please enter an signed number: 11

        You entered the following numbers:
        156, 34, -186, -145, 16, 23, 51, 0, 56, 11
        The sum of these numbers is: 16
        The truncated average is: 1
        That is a nice set of numbers. Thank you for choosing CS271. Goodbye!
