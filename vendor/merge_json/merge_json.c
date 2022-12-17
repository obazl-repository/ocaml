/* merge_json - simple merge of two json maps (objects)
 *  3 args: two fs paths or json map literals, a & b; one output file
 *  map b updates map a
 *  returns new map
 * does this:
 * function MergeJSON (a, b) {
 *   copy a to x
 *   for (var z in b) {
 *     x[z] = b[z];
 *   }
 *   return x;
 * }
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/errno.h>
#include <unistd.h>             /* getopt */

#include "ansi_colors.h"
#include "cjson/cJSON.h"

bool debug;
bool verbose;

static cJSON item[1];

cJSON *read_json(char *json_file) {
    errno = 0;
#ifdef DEBUG
        printf("cwd: %s\n", getcwd(NULL, 0));
#endif
    FILE *stream = fopen(json_file, "r");
    if (stream == NULL) {
        printf(RED "ERROR: " CRESET "fopen %s: %s\n",
               json_file, strerror(errno));
        return NULL;
#ifdef DEBUG
    } else {
        if (debug) printf("fopened %s\n", json_file);
#endif
    }
    fseek (stream, 0, SEEK_END);
    uint64_t filea_sz = ftell (stream);
    fseek (stream, 0, SEEK_SET);
    char * buffer = malloc (filea_sz);
    if (buffer) {
        fread(buffer, 1, filea_sz, stream);
    } else {
        printf("HUH?\n");
        fclose(stream);
        return NULL;
    }
#ifdef DEBUG
    printf("readed: %d\n", filea_sz);
#endif

    cJSON *json = cJSON_Parse((char*)buffer);
    /* cJSON *jsona = cJSON_ParseWithLength(buffer, filea_sz); */
    if (json == NULL) {
        printf(RED "cJSON_Parse error\n");
        const char *error_ptr = cJSON_GetErrorPtr();
        if (error_ptr != NULL) {
            fprintf(stderr, "Error before: %s\n", error_ptr);
        }
        /* status = 0; */
        goto end;
    }
 end:
    free(buffer);
    fclose(stream);
    return json;
}

cJSON *merge_json(char *filea, char *fileb, char *output)
{

    cJSON *jsona = read_json(filea);
    if (jsona == NULL) {
        printf(RED, "failed to read jsona: %s\n", filea);
        return NULL;
    }
    /* printf("readed jsona\n"); */
    cJSON *jsonb = read_json(fileb);
    if (jsonb == NULL) {
        printf(RED, "failed to read jsonb: %s\n", fileb);
        cJSON_Delete(jsona);
        return NULL;
    }
    /* printf("readed jsonb\n"); */

    char *jsonb_str = cJSON_Print(jsonb);
    if (jsonb_str == NULL) {
        fprintf(stdout, "Failed to print jsonb buffer.\n");
    } else {
        /* printf("parsed jsonb: %s\n", jsonb_str); */
        free(jsonb_str);
    }

    const cJSON *item = NULL;
    char *item_str;
    cJSON_ArrayForEach(item, jsonb) {
        item_str = cJSON_PrintUnformatted(item);
#ifdef DEBUG
        printf("jsonb item: %s : %s\n", item->string, item_str);
#endif
        cJSON_bool ok = cJSON_HasObjectItem(jsona, item->string);
#ifdef DEBUG
        printf("in jsona? %d\n", ok);
#endif
        if (cJSON_HasObjectItem(jsona, item->string)) {
#ifdef DEBUG
            printf("replacing %s\n", item->string);
#endif
            cJSON *obj = cJSON_GetObjectItem(jsona, item->string);
            if (cJSON_IsBool(item))
                cJSON_SetBoolValue(obj, item);
            if (cJSON_IsString(item))
                cJSON_SetValuestring(obj, item->valuestring);

            // elif cJSON_IsArray
        } else {
            /* adding item transfers ownership, which would crash delete */
            cJSON *new_item = cJSON_Duplicate(item, cJSON_False);
            cJSON *obj = cJSON_AddItemToObject(jsona, item->string, new_item);
        }
        free(item_str);
    }
    /* cJSON_Delete(jsonb); */

    char *jsona_str = cJSON_Print(jsona);
    if (jsona_str == NULL) {
        fprintf(stdout, "Failed to print jsona buffer.\n");
    } else {
        /* printf("parsed jsona: %s\n", jsona_str); */
        free(jsona_str);
    }

    /* cJSON *fld = cJSON_GetObjectItem(jsona, "flambda"); */
    /* if (fld == NULL) { */
    /*     fprintf(stdout, "Failed to get fld.\n"); */
    /* } else { */
    /*     char *fldstr = cJSON_Print(fld); */
    /*     printf("fld: %s\n", fldstr); */
    /* } */
    /* printf("flambda bool? %d\n", cJSON_IsBool(fld)); */
    /* printf("flambda true? %d\n", cJSON_IsTrue(fld)); */
    /* printf("flambda false? %d\n", cJSON_IsFalse(fld)); */
    /* cJSON_SetBoolValue(fld, cJSON_True); */


    cJSON_Delete(jsonb);

    return jsona;
}

void save_json(char *output, cJSON *map)
{
    char * json_string = cJSON_Print(map);
#ifdef DEBUG
    printf(json_string);
#endif
    errno = 0;
    FILE *ostream;
    ostream = fopen(output, "w");
    if (ostream == NULL) {
        printf(RED "%s\n", strerror(errno));
        free(json_string);
        return;
    }
    fprintf(ostream, json_string);
    fclose(ostream);
    free(json_string);
}

void print_usage(void)
{
    printf("HELP...\n");
}

int main(int argc, char **argv)
{
    /* printf("merge_json\n"); */

    /* json_b updates (overwrites) json_a */
    char *json_a = NULL;        /* path or json map */
    char *json_b = NULL;        /* path or json map */
    char *output = NULL;

    int opt;
    while ((opt = getopt(argc, argv, "a:b:j:o:dtvVh")) != -1) {
        switch (opt) {
        case 'a':
            json_a = strdup(optarg);
            break;
        case 'b':
            json_b = strdup(optarg);
            break;
        case 'o':
            output = strdup(optarg);
            break;
        case 'd':
            debug = true;
            break;
        case 'v':
            verbose =true;
            break;
        case 'V':
            printf("Version: 1.0\n");
            break;
        case 'h':
            print_usage();
            exit(EXIT_SUCCESS);
            break;
        default:
            print_usage();
            exit(EXIT_FAILURE);
        }
    }

    if (json_a == NULL) {
        printf("missing required arg: -a\n");
        exit(EXIT_FAILURE);
    }
    if (json_b == NULL) {
        printf("missing required arg: -b\n");
        exit(EXIT_FAILURE);
    }
    if (output == NULL) {
        printf("missing required arg: -o\n");
        exit(EXIT_FAILURE);
    }

    /* printf("json a: %s\n", json_a); */
    /* printf("json b: %s\n", json_b); */
    /* printf("output: %s\n", output); */

    cJSON *merged = merge_json(json_a, json_b, output);
    save_json(output, merged);

    /* printf("merge_json: freeing stuff\n"); */

    cJSON_Delete(merged);

    free(json_a);               /* string */
    free(json_b);               /* string */
    /* free(output); */
    /* printf("returning\n"); */
    return 0;
}

