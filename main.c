#include <stdio.h>
#include <stdbool.h>
#include <string.h>

int main(int argc, char *argv[]) {
	bool creating_files = false;

	char *first_arg = argv[1];

	if (argc > 1) {
		if (!strcmp(&first_arg[0], ".")) {
			creating_files = true;
		}
	}

	if (creating_files) {
		printf("Creating files...\n");
	}

	return 0;
}
