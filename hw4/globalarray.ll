; ModuleID = 'array global variable example'

@Foo = global [10 x i32] zeroinitializer

declare void @print_int(i32)

define i32 @main() {
entry:
  store i32 1, i32* getelementptr inbounds ([10 x i32]* @Foo, i32 0, i32 8)
  %loadtmp = load i32* getelementptr inbounds ([10 x i32]* @Foo, i32 0, i32 8)
  %addtmp = add i32 %loadtmp, 1
  store i32 %addtmp, i32* getelementptr inbounds ([10 x i32]* @Foo, i32 0, i32 8)
  call void @print_int(i32 %addtmp)
  ret i32 0
}
