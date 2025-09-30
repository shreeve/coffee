# BigInt and Advanced Numeric Features
# ===========================
# Tests for BigInt literals and advanced numeric features

# BigInt literals
test "typeof 123n", "bigint"
test "typeof 0n", "bigint"
test "456n > 400n", true
test "100n < 200n", true
test "50n === 50n", true

# BigInt arithmetic
test "10n + 20n", 30n
test "100n - 50n", 50n
test "5n * 6n", 30n
test "100n / 5n", 20n
test "17n % 5n", 2n
test "2n ** 3n", 8n

# BigInt with different bases
test "0b1010n", 10n
test "0o12n", 10n
test "0xAn", 10n
test "0xFFn", 255n

# BigInt with numeric separators
test "1_000n", 1000n
test "123_456_789n", 123456789n
test "0xFF_FFn", 65535n

# BigInt comparisons
test "100n > 50n", true
test "50n < 100n", true
test "100n >= 100n", true
test "100n <= 100n", true
test "100n === 100n", true
test "100n !== 200n", true

# BigInt with Math operations (should fail for most)
# test "Math.abs(-100n)", "should throw"
# test "Math.sqrt(100n)", "should throw"

# BigInt conversion
test "BigInt(100)", 100n
test "BigInt('100')", 100n
test "BigInt(true)", 1n
test "BigInt(false)", 0n

# BigInt in arrays and objects
test "[10n, 20n, 30n][1]", 20n
test "{value: 100n}.value", 100n

# Numeric separators in regular numbers
test "1_000", 1000
test "3.141_592", 3.141592
test "1_000.123_456", 1000.123456
test "1e1_0", 1e10
test "0b1010_1010", 170
test "0o123_456", 42798
test "0xFF_FF", 65535

# Scientific notation with separators
test "1.23e1_0", 1.23e10
test "1_0e2", 1000
test "1.5e+1_0", 1.5e10
test "1.5e-1_0", 1.5e-10

# Binary literals
test "0b0", 0
test "0b1", 1
test "0b10", 2
test "0b11", 3
test "0b1010", 10
test "0b11111111", 255

# Octal literals
test "0o0", 0
test "0o7", 7
test "0o10", 8
test "0o77", 63
test "0o100", 64
test "0o777", 511

# Hexadecimal literals
test "0x0", 0
test "0xF", 15
test "0x10", 16
test "0xFF", 255
test "0x100", 256
test "0xFFFF", 65535

# Case insensitive hex
test "0XFF", 255
test "0xfF", 255
test "0XfF", 255

# Special numeric values
test "Number.MAX_SAFE_INTEGER", 9007199254740991
test "Number.MIN_SAFE_INTEGER", -9007199254740991
test "Number.POSITIVE_INFINITY", Infinity
test "Number.NEGATIVE_INFINITY", -Infinity
test "Number.NaN", NaN

# Number methods
test "Number.isFinite(100)", true
test "Number.isFinite(Infinity)", false
test "Number.isInteger(100)", true
test "Number.isInteger(100.5)", false
test "Number.isSafeInteger(100)", true
test "Number.isNaN(NaN)", true
test "Number.isNaN(100)", false

# Underscores in various positions
test "1_2_3_4_5", 12345
test "1__000", undefined # double underscore should be invalid
test "_100", undefined # leading underscore should be invalid
test "100_", undefined # trailing underscore should be invalid
