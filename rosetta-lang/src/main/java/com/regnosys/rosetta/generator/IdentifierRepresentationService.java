package com.regnosys.rosetta.generator;

import jakarta.inject.Inject;

import org.eclipse.emf.ecore.EObject;

import com.regnosys.rosetta.utils.ImplicitVariableUtil;

public class IdentifierRepresentationService {
	@Inject
	private ImplicitVariableUtil implicitVarUtil;
	
	public ImplicitVariableRepresentation getImplicitVarInContext(EObject context) {
		EObject definingContainer = implicitVarUtil.findContainerDefiningImplicitVariable(context).orElseThrow();
		return new ImplicitVariableRepresentation(definingContainer);
	}
}
