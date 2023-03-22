package com.regnosys.rosetta.generator.java;

import com.regnosys.rosetta.generator.IdentifierRepresentationService;
import com.regnosys.rosetta.rosetta.simple.Function;
import com.regnosys.rosetta.types.RDataType;

public class JavaIdentifierRepresentationService extends IdentifierRepresentationService {
	public BlueprintImplicitVariableRepresentation toBlueprintImplicitVar(RDataType type) {
		return new BlueprintImplicitVariableRepresentation(type);
	}
	
	public FunctionInstanceRepresentation toFunctionInstance(Function func) {
		return new FunctionInstanceRepresentation(func);
	}
}
