#include <moonbit.h>
#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#ifdef _WIN32
#include <direct.h>
#include <windows.h>
#include <winsock2.h>
#define close closesocket
#define mkdir_one(path) _mkdir(path)
#else
#include <arpa/inet.h>
#include <dirent.h>
#include <netinet/in.h>
#include <strings.h>
#include <sys/socket.h>
#include <unistd.h>
#define mkdir_one(path) mkdir(path, 0755)
#endif

#ifndef S_ISDIR
#define S_ISDIR(mode) (((mode) & S_IFMT) == S_IFDIR)
#endif

static int ensure_parent_dirs(const char *path) {
  char *copy = strdup(path);
  if (!copy) return -1;
  for (char *p = copy + 1; *p; ++p) {
    if (*p == '/' || *p == '\\') {
      char saved = *p;
      *p = '\0';
      if (mkdir_one(copy) != 0 && errno != EEXIST) { free(copy); return -1; }
      *p = saved;
    }
  }
  free(copy);
  return 0;
}

MOONBIT_FFI_EXPORT int32_t moonbook_file_exists(moonbit_bytes_t path) {
  struct stat info;
  return stat((const char *)path, &info) == 0 && S_ISREG(info.st_mode);
}

MOONBIT_FFI_EXPORT moonbit_bytes_t moonbook_read_file(moonbit_bytes_t path) {
  FILE *file = fopen((const char *)path, "rb");
  if (!file) return moonbit_make_bytes(0, 0);
  if (fseek(file, 0, SEEK_END) != 0) { fclose(file); return moonbit_make_bytes(0, 0); }
  long size = ftell(file);
  rewind(file);
  if (size < 0 || size > INT32_MAX) { fclose(file); return moonbit_make_bytes(0, 0); }
  moonbit_bytes_t result = moonbit_make_bytes((int32_t)size, 0);
  if (size > 0 && fread(result, 1, (size_t)size, file) != (size_t)size) {
    fclose(file);
    return moonbit_make_bytes(0, 0);
  }
  fclose(file);
  return result;
}

static int same_content(const char *path, const uint8_t *content, int32_t length) {
  FILE *file = fopen(path, "rb");
  if (!file) return 0;
  if (fseek(file, 0, SEEK_END) != 0 || ftell(file) != length) { fclose(file); return 0; }
  rewind(file);
  uint8_t buffer[8192];
  int32_t offset = 0;
  while (offset < length) {
    size_t wanted = (size_t)(length - offset) > sizeof(buffer) ? sizeof(buffer) : (size_t)(length - offset);
    size_t got = fread(buffer, 1, wanted, file);
    if (got != wanted || memcmp(buffer, content + offset, got) != 0) { fclose(file); return 0; }
    offset += (int32_t)got;
  }
  fclose(file);
  return 1;
}

MOONBIT_FFI_EXPORT int32_t moonbook_write_file(moonbit_bytes_t path, moonbit_bytes_t content) {
  int32_t length = Moonbit_array_length(content);
  if (same_content((const char *)path, content, length)) return 0;
  if (ensure_parent_dirs((const char *)path) != 0) return -1;
  FILE *file = fopen((const char *)path, "wb");
  if (!file) return -1;
  int ok = length == 0 || fwrite(content, 1, (size_t)length, file) == (size_t)length;
  if (fclose(file) != 0) ok = 0;
  return ok ? 1 : -1;
}

static int has_markdown_extension(const char *name) {
  const char *dot = strrchr(name, '.');
  if (!dot) return 0;
#ifdef _WIN32
  return _stricmp(dot, ".md") == 0;
#else
  return strcasecmp(dot, ".md") == 0;
#endif
}

static int same_file(const char *source, const char *destination) {
  FILE *left = fopen(source, "rb");
  FILE *right = fopen(destination, "rb");
  if (!left || !right) { if (left) fclose(left); if (right) fclose(right); return 0; }
  uint8_t a[8192], b[8192];
  int equal = 1;
  for (;;) {
    size_t an = fread(a, 1, sizeof(a), left);
    size_t bn = fread(b, 1, sizeof(b), right);
    if (an != bn || memcmp(a, b, an) != 0) { equal = 0; break; }
    if (an < sizeof(a)) break;
  }
  fclose(left);
  fclose(right);
  return equal;
}

static int copy_one_file(const char *source, const char *destination) {
  if (same_file(source, destination)) return 0;
  if (ensure_parent_dirs(destination) != 0) return -1;
  FILE *input = fopen(source, "rb");
  FILE *output = fopen(destination, "wb");
  if (!input || !output) { if (input) fclose(input); if (output) fclose(output); return -1; }
  uint8_t buffer[8192];
  int ok = 1;
  for (;;) {
    size_t count = fread(buffer, 1, sizeof(buffer), input);
    if (count > 0 && fwrite(buffer, 1, count, output) != count) { ok = 0; break; }
    if (count < sizeof(buffer)) { if (ferror(input)) ok = 0; break; }
  }
  fclose(input);
  if (fclose(output) != 0) ok = 0;
  return ok ? 1 : -1;
}

static int copy_tree_impl(const char *source, const char *destination, int skip_markdown) {
  struct stat info;
  if (stat(source, &info) != 0) return 0;
  if (!S_ISDIR(info.st_mode)) return copy_one_file(source, destination);
  if (mkdir_one(destination) != 0 && errno != EEXIST) return -1;
  int changed = 0;
#ifdef _WIN32
  char pattern[4096];
  snprintf(pattern, sizeof(pattern), "%s\\*", source);
  WIN32_FIND_DATAA data;
  HANDLE handle = FindFirstFileA(pattern, &data);
  if (handle == INVALID_HANDLE_VALUE) return 0;
  do {
    const char *name = data.cFileName;
    if (!strcmp(name, ".") || !strcmp(name, "..") || (skip_markdown && has_markdown_extension(name))) continue;
    char child_source[4096], child_destination[4096];
    snprintf(child_source, sizeof(child_source), "%s\\%s", source, name);
    snprintf(child_destination, sizeof(child_destination), "%s\\%s", destination, name);
    int result = copy_tree_impl(child_source, child_destination, skip_markdown);
    if (result < 0) { FindClose(handle); return -1; }
    changed += result;
  } while (FindNextFileA(handle, &data));
  FindClose(handle);
#else
  DIR *directory = opendir(source);
  if (!directory) return -1;
  struct dirent *entry;
  while ((entry = readdir(directory)) != NULL) {
    const char *name = entry->d_name;
    if (!strcmp(name, ".") || !strcmp(name, "..") || (skip_markdown && has_markdown_extension(name))) continue;
    char child_source[4096], child_destination[4096];
    snprintf(child_source, sizeof(child_source), "%s/%s", source, name);
    snprintf(child_destination, sizeof(child_destination), "%s/%s", destination, name);
    int result = copy_tree_impl(child_source, child_destination, skip_markdown);
    if (result < 0) { closedir(directory); return -1; }
    changed += result;
  }
  closedir(directory);
#endif
  return changed;
}

MOONBIT_FFI_EXPORT int32_t moonbook_copy_tree(
  moonbit_bytes_t source,
  moonbit_bytes_t destination,
  int32_t skip_markdown
) {
  return copy_tree_impl((const char *)source, (const char *)destination, skip_markdown);
}

MOONBIT_FFI_EXPORT void moonbook_exit(int32_t code) {
  exit(code);
}

static const char *mime_type(const char *path) {
  const char *dot = strrchr(path, '.');
  if (!dot) return "application/octet-stream";
  if (!strcmp(dot, ".html")) return "text/html; charset=utf-8";
  if (!strcmp(dot, ".css")) return "text/css; charset=utf-8";
  if (!strcmp(dot, ".js")) return "text/javascript; charset=utf-8";
  if (!strcmp(dot, ".json")) return "application/json; charset=utf-8";
  if (!strcmp(dot, ".svg")) return "image/svg+xml";
  if (!strcmp(dot, ".png")) return "image/png";
  if (!strcmp(dot, ".jpg") || !strcmp(dot, ".jpeg")) return "image/jpeg";
  return "application/octet-stream";
}

static void send_response(int client, const char *status, const char *type, const uint8_t *body, long length) {
  char header[512];
  int header_length = snprintf(header, sizeof(header), "HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %ld\r\nConnection: close\r\n\r\n", status, type, length);
  send(client, header, (size_t)header_length, 0);
  long sent = 0;
  while (sent < length) {
    int amount = (int)send(client, (const char *)body + sent, (size_t)(length - sent), 0);
    if (amount <= 0) break;
    sent += amount;
  }
}

MOONBIT_FFI_EXPORT int32_t moonbook_serve(moonbit_bytes_t root_bytes, int32_t port) {
#ifdef _WIN32
  WSADATA data;
  if (WSAStartup(MAKEWORD(2, 2), &data) != 0) return -1;
#endif
  int server = (int)socket(AF_INET, SOCK_STREAM, 0);
  if (server < 0) return -1;
  int yes = 1;
  setsockopt(server, SOL_SOCKET, SO_REUSEADDR, (const char *)&yes, sizeof(yes));
  struct sockaddr_in address;
  memset(&address, 0, sizeof(address));
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  address.sin_port = htons((uint16_t)port);
  if (bind(server, (struct sockaddr *)&address, sizeof(address)) != 0 || listen(server, 16) != 0) { close(server); return -1; }
  const char *root = (const char *)root_bytes;
  for (;;) {
    int client = (int)accept(server, NULL, NULL);
    if (client < 0) continue;
    char request[4096] = {0};
    int count = (int)recv(client, request, sizeof(request) - 1, 0);
    char url[2048] = {0};
    if (count <= 0 || sscanf(request, "GET %2047s", url) != 1 || strstr(url, "..")) {
      const char *message = "Bad Request";
      send_response(client, "400 Bad Request", "text/plain", (const uint8_t *)message, (long)strlen(message));
      close(client);
      continue;
    }
    char *query = strchr(url, '?');
    if (query) *query = '\0';
    const char *relative = url[0] == '/' ? url + 1 : url;
    if (*relative == '\0') relative = "README.html";
    char path[4096];
    if (snprintf(path, sizeof(path), "%s/%s", root, relative) >= (int)sizeof(path)) { close(client); continue; }
    FILE *file = fopen(path, "rb");
    if (!file) {
      const char *message = "Not Found";
      send_response(client, "404 Not Found", "text/plain", (const uint8_t *)message, (long)strlen(message));
    } else {
      fseek(file, 0, SEEK_END);
      long length = ftell(file);
      rewind(file);
      uint8_t *body = length > 0 ? (uint8_t *)malloc((size_t)length) : NULL;
      if (length == 0 || (body && fread(body, 1, (size_t)length, file) == (size_t)length))
        send_response(client, "200 OK", mime_type(path), body, length);
      free(body);
      fclose(file);
    }
    close(client);
  }
}
