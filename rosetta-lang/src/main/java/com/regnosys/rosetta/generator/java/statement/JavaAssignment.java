package com.regnosys.rosetta.generator.java.statement;

import org.eclipse.xtend2.lib.StringConcatenationClient.TargetStringConcatenation;

import com.regnosys.rosetta.generator.GeneratedIdentifier;
import com.regnosys.rosetta.generator.java.statement.builder.JavaExpression;

/**
 * Based on the Java specification: https://docs.oracle.com/javase/specs/jls/se11/html/jls-15.html#jls-Assignment
 * 
 * Example: `x = 42;`
 * 
 * See `JavaStatement` for more documentation.
 */
public class JavaAssignment extends JavaStatement {

	private final GeneratedIdentifier variableId;
	private final JavaExpression expression;
	
	public JavaAssignment(GeneratedIdentifier variableId, JavaExpression expression) {
		this.variableId = variableId;
		this.expression = expression;
	}
	
	@Override
	public void appendTo(TargetStringConcatenation target) {
		target.append(variableId);
		target.append(" = ");
		target.append(expression);
		target.append(";");
	}
}
