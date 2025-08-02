#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
	bool creating_files = false;

	if (argc > 2) {
		creating_files = true;
	} else {
		if (argc == 2 && !strcmp(argv[1], "-i")) {
			printf("Installing...\n");
			system("sudo mv btouch /usr/local/bin");
			system("sudo chmod +x /usr/local/bin/btouch");
			printf("Moved btouch to /usr/local/bin\n");
			printf("Installed! Run with cmd btouch\n");
		} else {
			printf("Usage: btouch <.extension> <file1> <file2> ...\n");
			printf("OR: btouch <suffix> <file1> <file2> ...\n");
			printf("Note: ommit extension/suffix by leaving a space there instead.\n");
			printf("Note: if not installed, ./btouch -i to install.\n");
			return 1;
		}
	}

	char user_input[256];

	if (creating_files) {
		for (int i = 2; i < argc; i++) {
			snprintf(user_input, sizeof(user_input), "touch %s%s", argv[i], argv[1]);
			system(user_input);
		}
	}

	return 0;
}
