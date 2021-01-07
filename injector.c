#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <getopt.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/xattr.h>
#include <frida-core.h>


#define INFO(...) printf(__VA_ARGS__)

#define BANNER ("                                                                   \n" \
                "\t ██╗███╗   ██╗     ██╗███████╗ ██████╗████████╗ ██████╗ ██████╗  \n" \
                "\t ██║████╗  ██║     ██║██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗ \n" \
                "\t ██║██╔██╗ ██║     ██║█████╗  ██║        ██║   ██║   ██║██████╔╝ \n" \
                "\t ██║██║╚██╗██║██   ██║██╔══╝  ██║        ██║   ██║   ██║██╔══██╗ \n" \
                "\t ██║██║ ╚████║╚█████╔╝███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║ \n" \
                "\t ╚═╝╚═╝  ╚═══╝ ╚════╝ ╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ \n" \
                "                                                                   \n")


void show_usage(char *process)
{
    INFO("Usage for %s\n\n", process);
    INFO(" -p       pid\n");
    INFO(" -l       library path\n");
    INFO(" -e       entry point\n");
    exit(EXIT_FAILURE);
}

bool is_pid_running(pid_t pid)
{
    if (kill(pid, 0) == 0)
    {
        return true;
    }
    return false;
}

int main(int argc, char *argv[])
{
    int optch;
    pid_t pid = 0;
    char *library_path = NULL;
    char *entry_point = NULL;

    INFO(BANNER);

    while ((optch = getopt(argc, argv, "p:l:e:h")) != -1)
    {
        switch (optch)
        {
        case 'p':
            pid = atoi(optarg);
            break;
        case 'l':
            library_path = optarg;
            break;
        case 'e':
            entry_point = optarg;
            break;
        case 'h':
            show_usage(argv[0]);
            break;
        default:
            show_usage(argv[0]);
            break;
        }
    }

    if (pid == 0 || library_path == NULL)
    {
        show_usage(argv[0]);
    }
    else if (entry_point == NULL)
    {
        entry_point = "";
        INFO("[!] Entry point not provided, the target process might segfault!\n");
    }

    //
    // Check if PID is running
    //

    if (!is_pid_running(pid))
    {
        INFO("[-] Process not found: %d\n", pid);
        exit(EXIT_FAILURE);
    }

    //
    // Check if we are able to access the library that we want to inject
    //

    if (access(library_path, F_OK) == -1)
    {
        INFO("[-] Library path invalid or inaccessible: %s\n", library_path);
        exit(EXIT_FAILURE);
    }

    guint result;
    GError *error = NULL;
    FridaInjector *injector;
    const char *context = "u:object_r:frida_file:s0";

    //
    // Initialize Frida
    //

    frida_init();

    //
    // Patch SeLinux policies
    //

    INFO("[+] Patching SeLinux policy\n");

    frida_selinux_patch_policy();

    //
    // TODO: check for error
    //

    setxattr(library_path, XATTR_NAME_SELINUX, context, strlen(context) + 1, 0);

    //
    // Get new Frida injector instance
    //

    injector = frida_injector_new();

    INFO("[+] Injecting library: %s in pid: %d\n", library_path, pid);

    //
    // Perform the injection
    //

    result = frida_injector_inject_library_file_sync(injector, pid, library_path, entry_point, "", NULL, &error);

    if (error != NULL)
    {
        INFO("[-] Error while injecting: %s\n", error->message);
        g_clear_error(&error);
    }

    frida_injector_close_sync(injector, NULL, NULL);
    g_object_unref(injector);

    //
    // Deinitialize Frida
    //

    frida_deinit();

    INFO("[+] Injection completed\n");

    return result;
}
