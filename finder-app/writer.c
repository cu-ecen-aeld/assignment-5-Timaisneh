#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>

int main(int argc, char *argv[]) {

    // Open syslog with LOG_USER facility
    openlog("writer", LOG_PID, LOG_USER);
    
    // Check if both arguments are provided
    if (argc < 3) {
        fprintf(stderr, "Error: Please provide both writefile and writestr.\n");
        exit(EXIT_FAILURE);
    }

    // Extract arguments
    const char *writefile = argv[1];
    const char *writestr = argv[2];


    // Open the file in write mode
    FILE *file = fopen(writefile, "w");

    // Check if the file was opened successfully
    if (file == NULL) {
        // Log error using syslog
        syslog(LOG_ERR, "Error: Unable to open file '%s' for writing.", writefile);
        perror("fopen");
        exit(EXIT_FAILURE);
    }

    // Write the content to the file
    fprintf(file, "%s\n", writestr);

    // Close the file
    fclose(file);

    // Log the writing operation using syslog with LOG_DEBUG level
    syslog(LOG_DEBUG, "Writing '%s' to '%s'", writestr, writefile);

    // Close syslog
    closelog();

    return EXIT_SUCCESS;
}

