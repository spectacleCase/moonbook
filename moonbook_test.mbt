///|
test "project scaffold exposes its version and status" {
  assert_eq(@moonbook.version, "0.1.0")
  assert_eq(
    @moonbook.scaffold_status(),
    "MoonBook project scaffold initialized",
  )
}
