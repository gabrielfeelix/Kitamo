# Regras de ofuscação.
#
# O SQLite nativo e o local_auth entram por JNI/reflexão: sem estas regras,
# o minify remove classes que só são referenciadas em tempo de execução, e o
# app quebra apenas no release — onde é mais caro descobrir.
-keep class io.flutter.** { *; }
-keep class androidx.biometric.** { *; }
-keep class net.zetetic.** { *; }
-dontwarn io.flutter.embedding.**
