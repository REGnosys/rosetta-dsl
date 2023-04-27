/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.scoping

import com.google.common.base.Predicate
import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.generator.util.RosettaFunctionExtensions
import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalEnum
import com.regnosys.rosetta.rosetta.RosettaExternalEnumValue
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.expression.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.simple.AnnotationRef
import com.regnosys.rosetta.rosetta.simple.Condition
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.FunctionDispatch
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.rosetta.simple.Segment
import com.regnosys.rosetta.rosetta.simple.ShortcutDeclaration
import com.regnosys.rosetta.types.RosettaTypeProvider
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.FilteringScope
import org.eclipse.xtext.scoping.impl.ImportedNamespaceAwareLocalScopeProvider

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import static com.regnosys.rosetta.rosetta.simple.SimplePackage.Literals.*
import static com.regnosys.rosetta.rosetta.expression.ExpressionPackage.Literals.*
import com.regnosys.rosetta.rosetta.expression.InlineFunction
import com.regnosys.rosetta.rosetta.RosettaAttributeReference
import java.util.List
import org.eclipse.xtext.scoping.impl.SimpleScope
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.naming.QualifiedName
import com.regnosys.rosetta.rosetta.RosettaFeature
import com.regnosys.rosetta.utils.RosettaConfigExtension
import org.eclipse.xtext.resource.impl.AliasedEObjectDescription
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.RosettaNamed
import com.regnosys.rosetta.rosetta.expression.RosettaSymbolReference
import com.regnosys.rosetta.rosetta.expression.ChoiceOperation
import com.regnosys.rosetta.types.RType
import com.regnosys.rosetta.rosetta.RosettaTypeAlias
import com.regnosys.rosetta.rosetta.TypeCall
import com.regnosys.rosetta.rosetta.ParametrizedRosettaType

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class RosettaScopeProvider extends ImportedNamespaceAwareLocalScopeProvider {
	
	public val static LIB_NAMESPACE = 'com.rosetta.model'
	
	static Logger LOGGER = Logger.getLogger(RosettaScopeProvider)
	
	@Inject RosettaTypeProvider typeProvider
	@Inject extension RosettaExtensions
	@Inject extension RosettaConfigExtension configs
	@Inject extension RosettaFunctionExtensions

	override getScope(EObject context, EReference reference) {
		try {
			switch reference {
				case TYPE_CALL_ARGUMENT__PARAMETER: {
					if (context instanceof TypeCall) {
						val type = context.type
						if (type instanceof ParametrizedRosettaType) {
							return Scopes.scopeFor(type.parameters)
						}
						return IScope.NULLSCOPE
					}
				}
				case ROSETTA_FEATURE_CALL__FEATURE: {
					if (context instanceof RosettaFeatureCall) {
						return createExtendedFeatureScope(context.receiver, typeProvider.getRType(context.receiver))
					}
					return IScope.NULLSCOPE
				}
				case CHOICE_OPERATION__ATTRIBUTES: {
					if (context instanceof ChoiceOperation) {
						return createExtendedFeatureScope(context.argument, typeProvider.getRType(context.argument))
					}
					return IScope.NULLSCOPE
				}
				case ROSETTA_ATTRIBUTE_REFERENCE__ATTRIBUTE: {
					if (context instanceof RosettaAttributeReference) {
						return createExtendedFeatureScope(context.receiver, typeProvider.getRTypeOfAttributeReference(context.receiver))
					}
					return IScope.NULLSCOPE
				}
				case OPERATION__ASSIGN_ROOT: {
					if (context instanceof Operation) {
						val outAndAliases = newArrayList
						val out = getOutput(context.function)
						if (out !== null) {
							outAndAliases.add(out)
						}
						outAndAliases.addAll(context.function.shortcuts)
						return Scopes.scopeFor(outAndAliases)
					}
					return IScope.NULLSCOPE
				}
				case SEGMENT__ATTRIBUTE: {
					switch (context) {
						Operation: {
							val receiverType = typeProvider.getRTypeOfSymbol(context.assignRoot)
							return Scopes.scopeFor(receiverType.allFeatures(context.eResource.resourceSet))
						}
						Segment: {
							val prev = context.prev
							if (prev !== null) {
								if (prev.attribute.isResolved) {
									val receiverType = typeProvider.getRTypeOfSymbol(prev.attribute)
									return Scopes.scopeFor(receiverType.allFeatures(context.eResource.resourceSet))
								}
							}
							if (context.eContainer instanceof Operation) {
								return getScope(context.eContainer, reference)
							}
							return defaultScope(context, reference)
						}
						default:
							return defaultScope(context, reference)
					}
				}
				case ROSETTA_SYMBOL_REFERENCE__SYMBOL: {
					if (context instanceof Operation) {
						val function = context.function
						val inputsAndOutputs = newArrayList
						if(!function.inputs.nullOrEmpty)
							inputsAndOutputs.addAll(function.inputs)
						if(function.output!==null)
							inputsAndOutputs.add(function.output)
						return Scopes.scopeFor(inputsAndOutputs)
					} else {
						val implicitFeatures = findFeaturesOfImplicitVariable(context)
						
						val inline = EcoreUtil2.getContainerOfType(context, InlineFunction)
						if(inline !== null) {
							val ps = getSymbolParentScope(context, reference, IScope.NULLSCOPE)
							return Scopes.scopeFor(
								implicitFeatures.filterNamesThatAlreadyExist(ps),
								ps
							)
						}
						val container = EcoreUtil2.getContainerOfType(context, Function)
						if(container !== null) {
							val ps = filteredScope(getSymbolParentScope(context, reference, IScope.NULLSCOPE), [
								descr | descr.EClass !== DATA
							])
							return Scopes.scopeFor(
								implicitFeatures.filterNamesThatAlreadyExist(ps),
								ps
							)
						}
						
						val ps = getSymbolParentScope(context, reference, defaultScope(context, reference))
						return Scopes.scopeFor(
							implicitFeatures.filterNamesThatAlreadyExist(ps),
							ps
						)
					}
				}
				case ROSETTA_ENUM_VALUE_REFERENCE__VALUE: {
					if (context instanceof RosettaEnumValueReference) {
						return Scopes.scopeFor(context.enumeration.allEnumValues)
					}
					return IScope.NULLSCOPE
				}
				case ROSETTA_EXTERNAL_REGULAR_ATTRIBUTE__ATTRIBUTE_REF: {
					if (context instanceof RosettaExternalRegularAttribute) {
						val classRef = (context.eContainer as RosettaExternalClass).typeRef
						if (classRef instanceof Data)
							return Scopes.scopeFor(classRef.allAttributes)
					}
					return IScope.NULLSCOPE
				}			
				case ROSETTA_EXTERNAL_ENUM_VALUE__ENUM_REF: {
					if (context instanceof RosettaExternalEnumValue) {
						val enumRef = (context.eContainer as RosettaExternalEnum).typeRef
						if (enumRef instanceof RosettaEnumeration)
							return Scopes.scopeFor(enumRef.allEnumValues)
					}
					return IScope.NULLSCOPE
				}
				case ANNOTATION_REF__ATTRIBUTE: {
					if (context instanceof AnnotationRef) {
						val annoRef = context.annotation
						return Scopes.scopeFor(annoRef.attributes)
					}
					return IScope.NULLSCOPE
				}
				case FUNCTION_DISPATCH__ATTRIBUTE: {
					if (context instanceof FunctionDispatch) {
						return Scopes.scopeFor(getInputs(context))
					}
					return IScope.NULLSCOPE
				}
				case ROSETTA_EXTERNAL_RULE_SOURCE__SUPER_SOURCES: {
					return defaultScope(context, reference).filteredScope[it.EClass == ROSETTA_EXTERNAL_RULE_SOURCE]
				}
			}
			// LOGGER.warn('''No scope defined for «context.class.simpleName» referencing «reference.name».''')
			return defaultScope(context, reference)
		}
		catch (Exception e) {
			LOGGER.error ("Error scoping rosetta - \"" + e.message + "\" see debug logging for full trace");
			LOGGER.debug("Full trace of error ", e);
			//Any exception that is thrown here is going to have been caused by invalid grammar
			//However invalid grammar is checked as the next step of the process - after scoping
			//so just return an empty scope here and let the validator do its thing afterwards
			return IScope.NULLSCOPE;
		}
	}
	
	private def Iterable<? extends RosettaNamed> filterNamesThatAlreadyExist(Iterable<? extends RosettaNamed> features, IScope parentScope) {
		features.filter[
			parentScope.getSingleElement(QualifiedName.create(it.name)) === null
		]
	}
	
	override protected getImplicitImports(boolean ignoreCase) {
		#[createImportedNamespaceResolver(LIB_NAMESPACE + ".*", ignoreCase)]
	}
	
	override protected internalGetImportedNamespaceResolvers(EObject context, boolean ignoreCase) {
		return if (context instanceof RosettaModel) {
			val imports = super.internalGetImportedNamespaceResolvers(context, ignoreCase)
			imports.add(
				doCreateImportNormalizer(getQualifiedNameConverter.toQualifiedName(context.name), true, ignoreCase)
			)
			return imports
		} else
			emptyList
	}
	
	private def IScope defaultScope(EObject object, EReference reference) {
		filteredScope(super.getScope(object,reference), [it.EClass !== FUNCTION_DISPATCH])
	}
	
	private def IScope getSymbolParentScope(EObject object, EReference reference, IScope outer) {
		if (object === null) {
			return IScope.NULLSCOPE
		}
		val parentScope = getSymbolParentScope(object.eContainer, reference, outer)
		switch (object) {
			InlineFunction: {
				return Scopes.scopeFor(object.parameters, parentScope)
			}
			Function: {
				val features = newArrayList
				features.addAll(getInputs(object))
				val out = getOutput(object)
				if (out !== null)
					features.add(getOutput(object))
				features.addAll(object.shortcuts)
				return Scopes.scopeFor(features, parentScope)
			}
			ShortcutDeclaration: {
				filteredScope(parentScope, [descr|
					descr.qualifiedName.toString != object.name // TODO use qnames
				])
			}
			RosettaTypeAlias: {
				Scopes.scopeFor(object.parameters, parentScope)
			}
			Condition: {
				filteredScope(parentScope, [ descr |
					object.isPostCondition || descr.EObjectOrProxy.eContainingFeature !== FUNCTION__OUTPUT
				])
			}
			RosettaModel:
				filteredScope(defaultScope(object, reference))[ descr |
					#{DATA, ROSETTA_ENUMERATION, FUNCTION, ROSETTA_EXTERNAL_FUNCTION}.contains(descr.EClass)
				]
			default:
				parentScope
		}
	}
	
	def private IScope filteredScope(IScope scope, Predicate<IEObjectDescription> filter) {
		new FilteringScope(scope,filter)
	}
	
	private def Iterable<? extends RosettaFeature> findFeaturesOfImplicitVariable(EObject context) {
		val resourceSet = context.eResource?.resourceSet
		if (resourceSet === null) {
			return emptyList
		}
		return typeProvider.typeOfImplicitVariable(context).allFeatures(resourceSet)
	}
	
	private def IScope createExtendedFeatureScope(EObject receiver, RType receiverType) {
		val List<IEObjectDescription> allPosibilities = newArrayList
		allPosibilities.addAll(
			receiverType.allFeatures(receiver.eResource.resourceSet)
				.map[new EObjectDescription(QualifiedName.create(name), it, null)]
			
		)

		//if an attribute has metafields then the meta names are valid in a feature call e.g. -> currency -> scheme
		val feature = if (receiver instanceof RosettaFeatureCall) {
			receiver.feature
		} else if (receiver instanceof RosettaSymbolReference) {
			receiver.symbol
		}
		if (feature instanceof Attribute) {
			val metas = feature.metaAnnotations.map[it.attribute?.name].filterNull.toList
			if (metas !== null && !metas.isEmpty) {
				allPosibilities.addAll(configs.findMetaTypes(feature).filter[
					metas.contains(it.name.lastSegment.toString)
				].map[new AliasedEObjectDescription(QualifiedName.create(it.name.lastSegment), it)])
			}
		}
		
		return new SimpleScope(allPosibilities)
	}
}