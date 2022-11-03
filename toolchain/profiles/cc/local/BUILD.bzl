def fix_oc_cflags(x):
    if "-O2" in x:
        x.remove("-O2")
    if "-g" in x:
        x.remove("-g")

    return x
