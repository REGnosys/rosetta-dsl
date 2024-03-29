package com.regnosys.rosetta.generator.java.statement;

import org.eclipse.xtend2.lib.StringConcatenationClient.TargetStringConcatenation;

import com.regnosys.rosetta.generator.java.statement.builder.JavaExpression;

/**
 * Based on the Java specification: https://docs.oracle.com/javase/specs/jls/se11/html/jls-14.html#jls-ReturnStatement
 * 
 * Example: `return foo + 1;`
 * 
 * See `JavaStatement` for more documentation.
 */
public class JavaReturnStatement extends JavaStatement {
	private final JavaExpression expression;

	public JavaReturnStatement(JavaExpression expression) {
		this.expression = expression;
	}

	@Override
	public void appendTo(TargetStringConcatenation target) {
		target.append("return ");
		target.append(this.expression);
		target.append(";");
	}
}
