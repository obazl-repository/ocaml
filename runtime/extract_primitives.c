#include <assert.h>
#include <dirent.h>
#include <regex.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/errno.h>
#include <unistd.h>

extern char **environ;

#define ROWS 500
#define MAXLEN 45
char prims[ROWS][MAXLEN]; // v5.1 ct=~415, longest ~40 chars
int prim_ct = 0;

char ints[ROWS][MAXLEN]; // v5.1 ct=~?, longest ~? chars
int int_ct = 0;

int plen;

FILE *src_fp;
char fname[128];
char *linep = NULL;
size_t len = 0;
ssize_t read_ct;

int compare (const void *a, const void *b)
{
    return strncmp((const char*)a, (const char*)b, 40);
}

bool is_dup(int lasti, char tbl[][MAXLEN])
{
    char *last = tbl[lasti];
    for (int i = 0; i < lasti; i++) {
        if (strncmp((char*)tbl[i], last, MAXLEN) == 0) {
            fprintf(stdout, "DUP: %s\n", prims[i]);
            return true;
        }
    }
    return false;
}

void sed_ints_c(char *ints_c)
{
    fprintf(stdout, "SED %s\n", ints_c);
    regex_t ints_re;
    regmatch_t matches[10];
    int i = regcomp(&ints_re,
                    /* "^CAMLprim_int64_[0-9](([a-z0-9_][a-z0-9_]*)).*", */
                    "^CAMLprim_int64_[0-9]\\(([a-z0-9_][a-z0-9_]*)\\).*",
                    REG_EXTENDED);

    char fpath[128];
    sprintf(fpath, "runtime/ints.original.c"); //, gendir);

    errno = 0;
    src_fp = fopen(fpath, "r");
    if (src_fp == NULL) {
        fprintf(stdout, "fopen %s failure: %s\n",
                fpath,
                strerror(errno));
        exit(EXIT_FAILURE);
        /* return; */
    }

    fprintf(stdout, "Reading: %s\n", ints_c);
    errno = 0;
    linep = NULL;
    while ((read_ct = getline(&linep, &len, src_fp)) != -1) {
        /* fprintf(stdout, "LINE: %s", linep); */
        i = regexec(&ints_re, linep,
                    sizeof(matches)/sizeof(matches[0]),
                    (regmatch_t*)&matches,0);
        if (i == 0) {
            // extract match
            plen = matches[1].rm_eo - matches[1].rm_so;
            char *val
                = strndup(linep+matches[1].rm_so,
                          plen);
            fprintf(stdout, "matched: %d %s\n",
                    plen, (char*)val);
            strlcpy(ints[int_ct],
                    linep+matches[1].rm_so,
                    plen + 1);
            /* fprintf(stdout, "X %s\n", (char*)ints[int_ct]); */
            if (is_dup(int_ct, (char**)ints)) {
                ints[int_ct][0] = '\0';
                int_ct--;
            } else {
                /* fprintf(ints_fp, "%s\n", (char*)ints[int_ct]); */
            }
            int_ct++;
            /* free(val); */
        }
    }
}

int main(int argc, char **argv)
{
    char *ints_c = argv[1];

    /* int i = 0; */
    /* while(environ[i]) { */
    /*     printf("%s\n", environ[i++]); // prints in form of "variable=value" */
    /* } */

    regex_t prims_re;
    regmatch_t matches[10];
    int i = regcomp(&prims_re,
                    "^CAMLprim value ([a-z0-9_][a-z0-9_]*).*",
                    REG_EXTENDED);
    assert(i==0);

    fprintf(stderr, "PWD: %s\n", getcwd(NULL,0));
    /* fprintf(stderr, "BCR: %s\n", BAZEL_CURRENT_REPOSITORY); */
    /* fprintf(stderr, "WD: %s\n", */
    /*         getenv("BUILD_WORKSPACE_DIRECTORY")); */

    /* int files = 0; */
    struct dirent *entry;
    errno = 0;
    DIR *runtime = opendir("runtime");
    if(runtime == NULL){
        puts("Unable to read directory 'runtime'");
        return(1);
    } else {
        puts("Directory 'runtime' is opened!");
        while( (entry=readdir(runtime)) ) {
            /* files++; */
            /* printf("File %3d: %s\n", */
            /*        files, */
            /*        entry->d_name */
            /*        ); */
            if (strncmp(entry->d_name, ".", 1) == 0) continue;
            if (strncmp(entry->d_name, "..", 2) == 0) continue;
            sprintf(fname, "runtime/%s", entry->d_name);
            /* printf("opening %s\n", fname); */
            errno = 0;
            src_fp = fopen(fname, "r");
            if (src_fp == NULL) {
                fprintf(stderr, "fopen %s failure: %s\n",
                        fname,
                        strerror(errno));
                exit(EXIT_FAILURE);
            }

            fprintf(stderr, "Reading: %s\n", fname);
            errno = 0;
            linep = NULL;
            while ((read_ct = getline(&linep, &len, src_fp)) != -1) {
                /* fprintf(stderr, "LINE: %s", linep); */
                 i = regexec(&prims_re, linep,
                             sizeof(matches)/sizeof(matches[0]),
                             (regmatch_t*)&matches,0);
                 if (i == 0) {
                     // extract match
                     plen = matches[1].rm_eo - matches[1].rm_so;
                     char *val
                         = strndup(linep+matches[1].rm_so,
                                   plen);
                     fprintf(stdout, "matched: %d %s\n",
                             plen, (char*)val);
                     strlcpy(prims[prim_ct],
                             linep+matches[1].rm_so,
                             plen + 1);
                     /* fprintf(stdout, "X %s\n", (char*)prims[prim_ct]); */
                     if (is_dup(prim_ct, (char**)prims)) {
                         prims[prim_ct][0] = '\0';
                         prim_ct--;
                     } else {
                         /* fprintf(prims_fp, "%s\n", (char*)prims[prim_ct]); */
                     }
                     prim_ct++;
                     free(val);
                 }
            }
            if (errno != 0) {
                fprintf(stderr, "getline error: %s\n", strerror(errno));
            }
            /* else we hit eof */
            fclose(src_fp);
            /* fprintf(stderr, "closed %s\n", fname); */
            if (linep)
                free(linep);
        }
        closedir(runtime);
    }

    sed_ints_c(ints_c);
    qsort(ints, int_ct, MAXLEN, compare);
    fprintf(stdout, "ints ct: %d\n", int_ct);
    fprintf(stdout, "prims ct: %d\n", prim_ct);

    qsort(prims, prim_ct, MAXLEN, compare);

    FILE *prims_fp = fopen("primitives.dat", "w");
    if (prims_fp == NULL) {
        fprintf(stderr, "fopen %s failure: %s\n",
                "primitives",
                strerror(errno));
        exit(EXIT_FAILURE);
    }
    fprintf(prims_fp, "{\n");
    fprintf(prims_fp, "    \"primitives\": [\n");
    for (int i = 0; i < prim_ct; i++) {
        /* fprintf(stdout, "writing: %s\n", prims[i]); */
        fprintf(prims_fp, "        {\"prim\": \"%s\"}", prims[i]);
        if (i == (prim_ct - 1))
            fprintf(prims_fp, "\n");
        else
            fprintf(prims_fp, ",\n");
    }
    fprintf(prims_fp, "    ],\n");
    fprintf(prims_fp, "    \"int64\": [\n");
    for (int i = 0; i < int_ct; i++) {
        /* fprintf(stdout, "writing: %s\n", prims[i]); */
        fprintf(prims_fp, "        {\"int64\": \"%s\"}", ints[i]);
        if (i == (int_ct - 1))
            fprintf(prims_fp, "\n");
        else
            fprintf(prims_fp, ",\n");
    }
    fprintf(prims_fp, "    ]\n");
    fprintf(prims_fp, "}\n");
    fclose(prims_fp);
    fprintf(stderr, "PWD: %s\n", getcwd(NULL,0));

    exit(EXIT_SUCCESS);
}
