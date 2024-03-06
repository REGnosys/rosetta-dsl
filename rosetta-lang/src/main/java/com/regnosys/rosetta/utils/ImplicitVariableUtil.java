package com.regnosys.rosetta.utils;

import java.util.List;
import java.util.Optional;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.EcoreUtil2;

import com.regnosys.rosetta.rosetta.RosettaRule;
import com.regnosys.rosetta.rosetta.Translation;
import com.regnosys.rosetta.rosetta.TranslationParameter;
import com.regnosys.rosetta.rosetta.TranslationRule;
import com.regnosys.rosetta.rosetta.expression.ExpressionFactory;
import com.regnosys.rosetta.rosetta.expression.InlineFunction;
import com.regnosys.rosetta.rosetta.expression.RosettaExpression;
import com.regnosys.rosetta.rosetta.expression.RosettaFunctionalOperation;
import com.regnosys.rosetta.rosetta.expression.RosettaImplicitVariable;
import com.regnosys.rosetta.rosetta.simple.Data;

/**
 * A tool for finding information about implicit variables, often called
 * `this`, `item`, `it`, ...
 */
public class ImplicitVariableUtil {
	
	public RosettaImplicitVariable getDefaultImplicitVariable() {
		RosettaImplicitVariable def = ExpressionFactory.eINSTANCE.createRosettaImplicitVariable();
		def.setName("item");
		def.setGenerated(true);
		return def;
	}
	
	/**
	 * Find the enclosing object that defines the implicit variable in the given expression.
	 */
	public Optional<EObject> findObjectDefiningImplicitVariable(EObject context) {
		Iterable<EObject> containers = EcoreUtil2.getAllContainers(context);
		EObject prev = context;
		for (EObject container: containers) {
			if (container instanceof Data) {
				return Optional.of(container);
			} else if (container instanceof RosettaFunctionalOperation) {
				RosettaFunctionalOperation op = (RosettaFunctionalOperation)container;
				InlineFunction f = op.getFunction();
				if (f != null && f.equals(prev) && f.getParameters().size() == 0) {
					return Optional.of(container);
				}
			} else if (container instanceof RosettaRule) {
				return Optional.of(container);
			} else if (container instanceof TranslationRule) {
				TranslationRule rule = (TranslationRule)container;
				Translation trans = rule.getTranslation();
				TranslationParameter implicitParam = null;
				
				RosettaExpression left = rule.getLeft();
				if (left != null && left.equals(prev)) {
					implicitParam = findFirstUnnamedParameter(trans.getLeftParameters());
				} else {
					RosettaExpression right = rule.getRight();
					if (right != null && right.equals(prev)) {
						implicitParam = findFirstUnnamedParameter(trans.getRightParameters());
					}
				}
				
				if (implicitParam != null) {
					return Optional.of(implicitParam);
				}
			}
			prev = container;
		}
		return Optional.empty();
	}
	private TranslationParameter findFirstUnnamedParameter(List<TranslationParameter> params) {
		return params.stream().filter(p -> p.getName() == null).findFirst().orElse(null);
	}
	
	/**
	 * Indicates whether an implicit variable exists in the given context.
	 */
	public boolean implicitVariableExistsInContext(EObject context) {
		return findObjectDefiningImplicitVariable(context).isPresent();
	}
}
