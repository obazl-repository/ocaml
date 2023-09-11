/*
 Author: José Bollo <jobol@nonadev.net>

 https://gitlab.com/jobol/mustach

 SPDX-License-Identifier: ISC
 modified by: Gregg Reynolds <dev@mobileink.com>
*/

#define _GNU_SOURCE

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "mustach-wrap.h"

static const size_t BLOCKSIZE = 8192;

static const char *errors[] = {
	"??? unreferenced ???",
	"system",
	"unexpected end",
	"empty tag",
	"tag too long",
	"bad separators",
	"too depth",
	"closing",
	"bad unescape tag",
	"invalid interface",
	"item not found",
	"partial not found",
	"undefined tag"
};

static const char *errmsg = 0;
static int flags = 0;
static FILE *output = 0;

static void help(char *prog)
{
	char *name = basename(prog);
#define STR_INDIR(x) #x
#define STR(x) STR_INDIR(x)
	printf("%s version %s\n", name, STR(VERSION));
#undef STR
#undef STR_INDIR
	printf(
		"\n"
		"USAGE:\n"
		"    %s [FLAGS] -j <json-file> -t <mustach-templates...> -o <outfile>\n"
		"\n"
		"FLAGS:\n"
		"    -j     JSON infile\n"
		"    -t     Mustache template file\n"
		"    -o     Output file\n"
		"    -h     Prints help information\n"
		"    -s     Strict: error when a tag is undefined\n"
		"\n",
		name);
	exit(0);
}

static char *readfile(const char *filename, size_t *length)
{
	int f;
	struct stat s;
	char *result;
	size_t size, pos;
	ssize_t rc;

	result = NULL;
	if (filename[0] == '-' &&  filename[1] == 0)
		f = dup(0);
	else
		f = open(filename, O_RDONLY);
	if (f < 0) {
		fprintf(stderr, "Can't open file: %s\n", filename);
		exit(1);
	}

	fstat(f, &s);
	switch (s.st_mode & S_IFMT) {
	case S_IFREG:
		size = s.st_size;
		break;
	case S_IFSOCK:
	case S_IFIFO:
		size = BLOCKSIZE;
		break;
	default:
		fprintf(stderr, "Bad file: %s\n", filename);
		exit(1);
	}

	pos = 0;
	result = malloc(size + 1);
	do {
		if (result == NULL) {
			fprintf(stderr, "Out of memory\n");
			exit(1);
		}
		rc = read(f, &result[pos], (size - pos) + 1);
		if (rc < 0) {
			fprintf(stderr, "Error while reading %s\n", filename);
			exit(1);
		}
		if (rc > 0) {
			pos += (size_t)rc;
			if (pos > size) {
				size = pos + BLOCKSIZE;
				result = realloc(result, size + 1);
			}
		}
	} while(rc > 0);

	close(f);
	if (length != NULL)
		*length = pos;
	result[pos] = 0;
	return result;
}

void usage(void)
{
    fprintf(stdout, "Usage: mustache -j <jsonfile> -t <template> -o <outfile>\n");
}

static int load_json(const char *filename);
static int process(const char *content, size_t length);
static void close_json();

int main(int argc, char **argv)
{
    /* printf("CWD: %s\n", getcwd(NULL,0)); */
    /* printf("BUILD_WORKSPACE_DIRECTORY: %s\n", */
    /*        getenv("BUILD_WORKSPACE_DIRECTORY")); */

    /* printf("RUNFILES_DIR: %s\n", getenv("RUNFILES_DIR")); */
    /* printf("RUNFILES_MANIFEST_FILE: %s\n", */
    /*        getenv("RUNFILES_MANIFEST_FILE")); */
    /* printf("BAZEL_CURRENT_REPOSITORY: %s\n", BAZEL_CURRENT_REPOSITORY); */
    char *json_infile = NULL;
    char *template_infile = NULL;
    char *outfile = NULL;
    char *template_str;

    /* char *t, *f; */
    char *prog = *argv;
    int s;
    size_t length;

    (void)argc; /* unused */
    flags = Mustach_With_AllExtensions;
    output = stdout;

    opterr = 0;

    int c;
    while ((c = getopt (argc, argv, "j:t:o:h")) != -1) {
        switch (c) {
        case 'j':
            json_infile = optarg;
            break;
        case 't':
            template_infile = optarg;
            break;
        case 'o':
            outfile = optarg;
            break;
        case 's':
            flags |= Mustach_With_ErrorUndefined;
            break;
        case 'h':
            help(prog);
            exit(EXIT_SUCCESS);
            break;
        case '?':
            if ((optopt == 'j') || (optopt == 't') || (optopt == 'o'))
                fprintf (stderr, "Option -%c requires an argument.\n", optopt);
            else if (isprint (optopt))
                fprintf (stderr, "Unknown option `-%c'.\n", optopt);
            else
                fprintf (stderr,
                         "Unknown option character `\\x%x'.\n",
                         optopt);
            return 1;
        default:
            abort ();
        }
    }

    if (json_infile == NULL) {
        fprintf(stdout, "Missing -j <jsonfile>\n");
        exit(EXIT_FAILURE);
    }
    if (template_infile == NULL) {
        fprintf(stdout, "Missing -t <template>\n");
        exit(EXIT_FAILURE);
    }

    

    errno = 0;
    output = fopen(outfile, "w");
    if (output == NULL) {
        fprintf(stdout, "%s", strerror(errno));
        exit(EXIT_FAILURE);
    }

    s = load_json(json_infile);
    if (s < 0) {
        fprintf(stderr, "Can't load json file %s\n", json_infile);
        if(errmsg)
            fprintf(stderr, "   reason: %s\n", errmsg);
        exit(1);
    }

    template_str = readfile(template_infile, &length);
    s = process(template_str, length);
    free(template_str);
    if (s != MUSTACH_OK) {
        s = -s;
        if (s < 1 || s >= (int)(sizeof errors / sizeof * errors))
            s = 0;
        fprintf(stderr, "Template error %s (file %s)\n", errors[s], template_infile);
    }
    fclose(output);
    close_json();

    return 0;
}

#define MUSTACH_TOOL_JSON_C  1
#define MUSTACH_TOOL_JANSSON 2
#define MUSTACH_TOOL_CJSON   3

#if TOOL == MUSTACH_TOOL_JSON_C

#include "mustach-json-c.h"

static struct json_object *o;
static int load_json(const char *filename)
{
	o = json_object_from_file(filename);
#if JSON_C_VERSION_NUM >= 0x000D00
	errmsg = json_util_get_last_err();
	if (errmsg != NULL)
		return -1;
#endif
	if (o == NULL) {
		errmsg = "null json";
		return -1;
	}
	return 0;
}
static int process(const char *content, size_t length)
{
	return mustach_json_c_file(content, length, o, flags, output);
}
static void close_json()
{
	json_object_put(o);
}

#elif TOOL == MUSTACH_TOOL_JANSSON

#include "mustach-jansson.h"

static json_t *o;
static json_error_t e;
static int load_json(const char *filename)
{
	o = json_load_file(filename, JSON_DECODE_ANY, &e);
	if (o == NULL) {
		errmsg = e.text;
		return -1;
	}
	return 0;
}
static int process(const char *content, size_t length)
{
	return mustach_jansson_file(content, length, o, flags, output);
}
static void close_json()
{
	json_decref(o);
}

#elif TOOL == MUSTACH_TOOL_CJSON

#include "mustach-cjson.h"

static cJSON *o;
static int load_json(const char *filename)
{
	char *t;
	size_t length;

	t = readfile(filename, &length);
	o = t ? cJSON_ParseWithLength(t, length) : NULL;
	free(t);
	return -!o;
}
static int process(const char *content, size_t length)
{
	return mustach_cJSON_file(content, length, o, flags, output);
}
static void close_json()
{
	cJSON_Delete(o);
}

#else
#error "no defined json library"
#endif
