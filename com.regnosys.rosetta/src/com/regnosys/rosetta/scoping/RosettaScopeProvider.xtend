/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.scoping

import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.rosetta.RosettaArguments
import com.regnosys.rosetta.rosetta.RosettaBinaryOperation
import com.regnosys.rosetta.rosetta.RosettaChoiceRule
import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.RosettaGroupByExpression
import com.regnosys.rosetta.rosetta.RosettaGroupByFeatureCall
import com.regnosys.rosetta.rosetta.RosettaRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaWorkflowRule
import com.regnosys.rosetta.rosetta.simple.AnnotationRef
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.types.RClassType
import com.regnosys.rosetta.types.RDataType
import com.regnosys.rosetta.types.RFeatureCallType
import com.regnosys.rosetta.types.RRecordType
import com.regnosys.rosetta.types.RType
import com.regnosys.rosetta.types.RUnionType
import com.regnosys.rosetta.types.RosettaTypeProvider
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.resource.IResourceDescriptionsProvider
import org.eclipse.xtext.resource.impl.AliasedEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.MapBasedScope
import org.eclipse.xtext.scoping.impl.SimpleScope

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import static com.regnosys.rosetta.rosetta.simple.SimplePackage.Literals.*

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class RosettaScopeProvider extends AbstractRosettaScopeProvider {

	@Inject RosettaTypeProvider typeProvider
	@Inject extension RosettaExtensions
	@Inject IResourceDescriptionsProvider indexProvider
	@Inject IQualifiedNameProvider qNames

	override getScope(EObject context, EReference reference) {
		switch reference {
			case ROSETTA_GROUP_BY_EXPRESSION__ATTRIBUTE:
				if (context instanceof RosettaGroupByFeatureCall) {
					val featureCall = context.call
					if (featureCall instanceof RosettaFeatureCall) {
						val receiverType = typeProvider.getRType(featureCall.feature)
						val featureScope = receiverType.createFeatureScope
						if (featureScope !== null)
							return featureScope
					}
					return IScope.NULLSCOPE
				} else if (context instanceof RosettaGroupByExpression) {
					val container = context.eContainer
					if (container instanceof RosettaGroupByFeatureCall) {
						val featureCall = container.call
						if (featureCall instanceof RosettaFeatureCall) {
							val receiverType = typeProvider.getRType(featureCall.feature)
							val featureScope = receiverType.createFeatureScope
							if (featureScope !== null)
								return featureScope
						}
					}
					else if (container instanceof RosettaGroupByExpression) {
						val parentType = typeProvider.getRType(container.attribute)
						val featureScope = parentType.createFeatureScope
							if (featureScope !== null)
								return featureScope
					}
					return IScope.NULLSCOPE
				}
			case ROSETTA_FEATURE_CALL__FEATURE: {
				if (context instanceof RosettaFeatureCall) {
					val receiverType = typeProvider.getRType(context.receiver)
					val featureScope = receiverType.createFeatureScope
					var allPosibilities = newArrayList
					
					if (featureScope!==null) {
						allPosibilities.addAll(featureScope.allElements);
					}
					//if an attribute has metafields then then the meta names are valid in a feature call e.g. -> currency -> scheme
					val receiver = context.receiver;
					if (receiver instanceof RosettaFeatureCall) {
						val feature = receiver.feature
						if (feature instanceof RosettaRegularAttribute) {
							val metas = feature.metaTypes;
							if (metas!==null && !metas.isEmpty) {
								val metaScope = Scopes.scopeFor(metas)
								allPosibilities.addAll(metaScope.allElements);
							}
						}
					}
					return new SimpleScope(allPosibilities)
				}
				return IScope.NULLSCOPE
			}
			case ROSETTA_CALLABLE_CALL__CALLABLE: {
				if (context instanceof RosettaWorkflowRule) {
					val parent = context.root?.parent
					if (parent !== null) {
						val allClasses = parent.allSuperTypes
						val scope = Scopes.scopeFor(allClasses)
						return scope
					}
				} else if (context instanceof Operation) {
					val function = context.function
					val inputsAndOutputs = newArrayList
					inputsAndOutputs.addAll(function.inputs)
					inputsAndOutputs.add(function.output)
					return Scopes.scopeFor(inputsAndOutputs)
				}
				 /*else if (context instanceof RosettaFuncitonCondition) {
					val function = (context.eContainer as RosettaFunction)
					
					if (context.type == RosettaFunctionConditionType.PRE) {
						return Scopes.scopeFor(function.inputs)	
					} else {
						val inputsAndOutputs = newArrayList
						inputsAndOutputs.addAll(function.inputs)
						inputsAndOutputs.add(function.output)
						
						return Scopes.scopeFor(inputsAndOutputs)
					}
				}*/ else {
					val calculationTarget = EcoreUtil2.getContainerOfType(context, RosettaArguments)?.calculation
					if (calculationTarget !== null) {
						val index = indexProvider.getResourceDescriptions(context.eResource.resourceSet)
						val synonymDescriptions = index.getExportedObjectsByType(ROSETTA_ALIAS).filter [
							it.qualifiedName.startsWith(qNames.getFullyQualifiedName(calculationTarget))
						].map [
							new AliasedEObjectDescription(QualifiedName.create(qualifiedName.lastSegment),
								it) as IEObjectDescription
						]
						return MapBasedScope.createScope(super.getScope(context, reference), synonymDescriptions, false)
					}
				}
				return super.getScope(context, reference)
			}
			case ROSETTA_ENUM_VALUE_REFERENCE__VALUE: {
				if (context instanceof RosettaEnumValueReference) {
					return Scopes.scopeFor(context.enumeration.allEnumValues)
				}
				return IScope.NULLSCOPE
			}
			case ROSETTA_CHOICE_RULE__THIS_ONE: {
				if (context instanceof RosettaChoiceRule) {
					val choiceScope = context.scope
					return Scopes.scopeFor(choiceScope.allAttributes)
				}
				return IScope.NULLSCOPE
			}
			case ROSETTA_CHOICE_RULE__THAT_ONES: {
				if (context instanceof RosettaChoiceRule) {
					val choiceScope = context.scope
					return Scopes.scopeFor(choiceScope.allAttributes)
				}
				return IScope.NULLSCOPE
			}
			case ROSETTA_WORKFLOW_RULE__COMMON_IDENTIFIER:
				if (context instanceof RosettaWorkflowRule) {
					val parent = context.root?.parent
					if (parent !== null) {
						return Scopes.scopeFor(parent.allAttributes)
					}
				}
			case ROSETTA_ENUM_VALUE_REFERENCE__ENUMERATION: {
				if (context instanceof RosettaEnumValueReference || context instanceof RosettaBinaryOperation) {
					return super.getScope(context, reference)
				}
				return IScope.NULLSCOPE
			}
			case ROSETTA_EXTERNAL_REGULAR_ATTRIBUTE__ATTRIBUTE_REF: {
				if (context instanceof RosettaExternalRegularAttribute) {
					val classRef = (context.eContainer as RosettaExternalClass).classRef
					if(classRef !==null)
						return Scopes.scopeFor(classRef.allAttributes)
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
		}
		super.getScope(context, reference)
	}

	private def IScope createFeatureScope(RType receiverType) {
		switch receiverType {
			RClassType:
				Scopes.scopeFor(receiverType.clazz.allAttributes)
			RDataType:
				Scopes.scopeFor(receiverType.data.attributes)
			RRecordType:
				Scopes.scopeFor(receiverType.record.features)
			RFeatureCallType:
				receiverType.featureType.createFeatureScope
			RUnionType:
				Scopes.scopeFor(receiverType.converter.features)
			default:
				null
		}
	}
}