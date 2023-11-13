package com.regnosys.rosetta.generator.java.statement;

import org.eclipse.xtend2.lib.StringConcatenationClient.TargetStringConcatenation;

import com.regnosys.rosetta.generator.GeneratedIdentifier;
import com.regnosys.rosetta.generator.java.JavaScope;
import com.rosetta.util.types.JavaType;

public class JavaVariable extends JavaExpression {
	private final GeneratedIdentifier id;

	public JavaVariable(GeneratedIdentifier id, JavaType type) {
		super(type);
		this.id = id;
	}
	
	@Override
	public JavaStatementBuilder declareAsVariable(boolean isFinal, String variableId, JavaScope scope) {
		scope.createSynonym(this, id);
		return this;
	}

	@Override
	public void appendTo(TargetStringConcatenation target) {
		target.append(id);
	}
}