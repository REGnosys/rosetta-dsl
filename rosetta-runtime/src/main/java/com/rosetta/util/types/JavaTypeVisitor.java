package com.rosetta.util.types;

public interface JavaTypeVisitor {
	void visitType(JavaArrayType type);
	void visitType(JavaClass type);
	void visitType(JavaInterface type);
	void visitType(JavaParametrizedType type);
	void visitType(JavaPrimitiveType type);
	void visitType(JavaTypeVariable type);
}