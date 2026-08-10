///|
#borrow(path)
extern "c" fn file_exists_raw(path : Bytes) -> Int = "moonbook_file_exists"

///|
#borrow(path)
extern "c" fn read_file_raw(path : Bytes) -> Bytes = "moonbook_read_file"

///|
#borrow(path, content)
extern "c" fn write_file_raw(path : Bytes, content : Bytes) -> Int = "moonbook_write_file"

///|
#borrow(root)
extern "c" fn serve_raw(root : Bytes, port : Int) -> Int = "moonbook_serve"

///|
fn file_exists(path : String) -> Bool {
  file_exists_raw(@utf8.encode(path)) == 1
}

///|
fn read_file(path : String) -> String? {
  if !file_exists(path) {
    return None
  }
  Some(@utf8.decode_lossy(read_file_raw(@utf8.encode(path))))
}

///|
fn write_file(path : String, content : String) -> Int {
  write_file_raw(@utf8.encode(path), @utf8.encode(content))
}

///|
fn serve_directory(path : String, port : Int) -> Int {
  serve_raw(@utf8.encode(path), port)
}
