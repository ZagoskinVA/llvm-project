; RUN: llc -mtriple=arm64-apple-ios -mattr=+strict-align < %s | FileCheck %s

; Small (16 bytes here) unaligned memcpy() should be a function call if
; strict-alignment is turned on.
define void @t0(i8* %out, i8* %in) {
; CHECK-LABEL: t0:
; CHECK:      mov w2, #16
; CHECK-NEXT: bl _memcpy
entry:
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %out, i8* %in, i64 16, i1 false)
  ret void
}

; Small (16 bytes here) aligned memcpy() should be inlined even if
; strict-alignment is turned on.
define void @t1(i8* align 8 %out, i8* align 8 %in) {
; CHECK-LABEL: t1:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    ldp x9, x8, [x1]
; CHECK-NEXT:    stp x9, x8, [x0]
; CHECK-NEXT:    ret
entry:
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 8 %out, i8* align 8 %in, i64 16, i1 false)
  ret void
}

; Tiny (4 bytes here) unaligned memcpy() should be inlined with byte sized
; loads and stores if strict-alignment is turned on.
define void @t2(i8* %out, i8* %in) {
; CHECK-LABEL: t2:
; CHECK:       ; %bb.0: ; %entry
; CHECK-NEXT:    ldrb w8, [x1, #3]
; CHECK-NEXT:    ldrb w9, [x1, #2]
; CHECK-NEXT:    ldrb w10, [x1, #1]
; CHECK-NEXT:    ldrb w11, [x1]
; CHECK-NEXT:    strb w8, [x0, #3]
; CHECK-NEXT:    strb w9, [x0, #2]
; CHECK-NEXT:    strb w10, [x0, #1]
; CHECK-NEXT:    strb w11, [x0]
; CHECK-NEXT:    ret
entry:
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %out, i8* %in, i64 4, i1 false)
  ret void
}

declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1)
