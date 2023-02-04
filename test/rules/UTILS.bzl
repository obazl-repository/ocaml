################################################################
std_compilers = ["ocamlc.byte", "ocamlc.opt", "ocamlc.optx",
                 "ocamlopt.byte", "ocamlopt.opt", "ocamlopt.optx",
                 "ocamloptx.byte","ocamloptx.opt", "ocamloptx.optx"]

#############################################
def validate_io_files(stdout_expected = None,
                      stdout_actual = None,
                      stderr_expected = None,
                      stderr_actual = None,
                      stdlog_expected = None,
                      stdlog_actual = None):

    if (stdout_actual == None
        and stderr_actual == None
        and stdlog_actual == None):
        fail("One of stdout_actual, stderr_actual, or stdlog_actual must be specified")

    if stdout_actual:
        if not stdout_expected:
            fail("stdout_actual must have corresponding stdout_expected")
    if stdout_expected:
        if not stdout_actual:
            fail("stdout_expected must have corresponding stdout_actual")

    # if stderr_actual:
    #     if stderr_expected == None:
    #         print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    #         fail()
    #     if not stderr_expected:
    #         fail("stderr_actual must have corresponding stderr_expected")
    if stderr_expected:
        if not stderr_actual:
            fail("stderr_expected must have corresponding stderr_actual")

    if stdlog_actual:
        if not stdlog_expected:
            fail("stdlog_actual must have corresponding stdlog_expected")
    if stdlog_expected:
        if not stdlog_actual:
            fail("stdlog_expected must have corresponding stdlog_actual")

    return True
