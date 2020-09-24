; ModuleID = 'triple.ll'

declare i32 @printf(i8* nocapture readonly, ...)

@msg = private constant [4 x i8] c"%i\0A\00"

define i32 @triple(i32 %n) {
entry:
  %temp = mul nsw i32 %n, 3
  ret i32 %temp
}

define i32 @main() {
start:
  %result = call i32 @triple(i32 5)
  %str = getelementptr [4 x i8], [4 x i8]* @msg, i64  0, i64 0
  call i32 (i8*, ...) @printf(i8* %str, i32 %result)
  ret i32 0
}
