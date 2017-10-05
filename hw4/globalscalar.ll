; ModuleID = 'global scalar values and print_string example'

@Foo = internal global i32 0
@GlobalStr = private unnamed_addr constant [15 x i8] c"\0Ahello, world\0A\00"

declare void @print_string(i8*)

declare void @print_int(i32)

define i32 @main() {
entry:
  %footmp = load i32* @Foo
  %addtmp = add i32 %footmp, 1
  call void @print_int(i32 %addtmp)
  call void @print_string(i8* getelementptr inbounds ([15 x i8]* @GlobalStr, i32 0, i32 0))
  ret i32 0
}
