/*
 * Copyright 2024 REGnosys
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.regnosys.rosetta.generator;

import javax.inject.Inject;

import org.eclipse.emf.ecore.EObject;

import com.regnosys.rosetta.utils.ImplicitVariableUtil;

public class IdentifierRepresentationService {
	@Inject
	private ImplicitVariableUtil implicitVarUtil;
	
	public ImplicitVariableRepresentation getImplicitVarInContext(EObject context) {
		EObject definingContainer = implicitVarUtil.findObjectDefiningImplicitVariable(context).orElseThrow();
		return new ImplicitVariableRepresentation(definingContainer);
	}
}
