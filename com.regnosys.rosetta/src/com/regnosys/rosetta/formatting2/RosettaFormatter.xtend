/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.formatting2

import com.google.inject.Inject
import com.regnosys.rosetta.rosetta.RosettaClassSynonym
import com.regnosys.rosetta.rosetta.RosettaDocReference
import com.regnosys.rosetta.rosetta.RosettaEnumSynonym
import com.regnosys.rosetta.rosetta.RosettaEnumValue
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.expression.RosettaExpression
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalEnum
import com.regnosys.rosetta.rosetta.RosettaExternalEnumValue
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaExternalSynonym
import com.regnosys.rosetta.rosetta.RosettaExternalSynonymSource
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.RosettaSynonym
import com.regnosys.rosetta.rosetta.simple.AnnotationRef
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Condition
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.rosetta.simple.ShortcutDeclaration
import com.regnosys.rosetta.services.RosettaGrammarAccess
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.IHiddenRegionFormatter
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.xtext.formatting2.FormatterRequest

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*
import com.regnosys.rosetta.rosetta.RosettaCardinality
import com.regnosys.rosetta.rosetta.BlueprintNodeExp
import com.regnosys.rosetta.rosetta.RosettaBlueprint
import com.regnosys.rosetta.rosetta.RosettaDefinable
import com.regnosys.rosetta.rosetta.simple.FunctionDispatch
import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.simple.Segment
import com.regnosys.rosetta.rosetta.RosettaSynonymSource
import com.regnosys.rosetta.rosetta.RosettaRootElement
import com.regnosys.rosetta.rosetta.RosettaBody
import com.regnosys.rosetta.rosetta.RosettaCorpus
import com.regnosys.rosetta.rosetta.RosettaSegment
import com.regnosys.rosetta.rosetta.RosettaBasicType
import com.regnosys.rosetta.rosetta.RosettaRecordType
import com.regnosys.rosetta.rosetta.RosettaQualifiedType
import com.regnosys.rosetta.rosetta.RosettaCalculationType
import com.regnosys.rosetta.rosetta.RosettaMetaType
import com.regnosys.rosetta.rosetta.RosettaExternalFunction
import com.regnosys.rosetta.rosetta.simple.Annotation

class RosettaFormatter extends AbstractRosettaFormatter2 {
	
	static val Procedure1<? super IHiddenRegionFormatter> NO_SPACE = [noSpace]
	static val Procedure1<? super IHiddenRegionFormatter> ONE_SPACE = [oneSpace]
	
	@Inject extension RosettaGrammarAccess
	@Inject RosettaExpressionFormatter expressionFormatter
	@Inject extension FormattingUtil
	
	protected override void initialize(FormatterRequest request) {
		super.initialize(request)
		expressionFormatter.initialize(request)
	}
	
	def dispatch void format(RosettaModel rosettaModel, extension IFormattableDocument document) {
		val extension modelGrammarAccess = rosettaModelAccess
				
		rosettaModel.regionFor.keyword(namespaceKeyword_0)
			.prepend[noSpace]
			.append[oneSpace]
		rosettaModel.regionFor.keyword(versionKeyword_3_0)
			.prepend[newLine]
			.append[oneSpace]
		
		val groupedElementTypes = #[RosettaBody, RosettaCorpus, RosettaSegment, RosettaBasicType, 
			RosettaRecordType, RosettaExternalFunction, RosettaQualifiedType, RosettaCalculationType,
			RosettaMetaType
		]
		var Class<? extends RosettaRootElement> lastType = null
		for (elem: rosettaModel.elements) {
			// Root elements are separated by an empty lines, except
			// for elements such as `metaType`s, `basicType`s, etc.
			// They are grouped together.
			if (groupedElementTypes.exists[isInstance(elem)]) {
				if (elem.getClass().equals(lastType)) {
					elem.prepend[newLine]
				} else {
					elem.prepend[setNewLines(2)]
				}
			} else {
				elem.prepend[setNewLines(2)]
			}
			elem.format
			lastType = elem.getClass()
		}
		
		// Always end with a single newline
		rosettaModel.nextHiddenRegion.previousSemanticRegion
			.append[newLine]
	}
	
	
	def dispatch void format(RosettaBasicType ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(rosettaBasicTypeAccess.basicTypeKeyword_0)
			.append[oneSpace]
	}
	
	def dispatch void format(RosettaExternalFunction ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(rosettaLibraryFunctionAccess.functionKeyword_1)
			.surround[oneSpace]
		ele.regionFor.keyword('(')
			.surround[noSpace]
		ele.regionFor.keyword(')')
			.prepend[noSpace]
			.append[oneSpace]
		ele.regionFor.keywords(',').forEach[
			prepend[noSpace]
			append[oneSpace]
		]
		ele.parameters.forEach[
			regionFor.assignment(rosettaTypedAccess.typeAssignment)
				.prepend[oneSpace]
		]
		ele.formatDefinition(document)
	}
	
	def dispatch void format(RosettaBody ele, extension IFormattableDocument document) {
		val extension bodyGrammarAccess = rosettaBodyAccess
		
		ele.regionFor.assignment(bodyTypeAssignment_1)
			.surround[oneSpace]
		ele.formatDefinition(document)
	}
	
	def dispatch void format(RosettaCorpus ele, extension IFormattableDocument document) {
		val extension corpusGrammarAccess = rosettaCorpusAccess
		
		ele.regionFor.assignment(corpusTypeAssignment_1)
			.prepend[oneSpace]
		ele.regionFor.assignment(bodyAssignment_2)
			.prepend[oneSpace]
		ele.regionFor.assignment(displayNameAssignment_3)
			.prepend[oneSpace]
		ele.regionFor.assignment(rosettaNamedAccess.nameAssignment)
			.prepend[oneSpace]
		ele.formatDefinition(document)
	}
	
	def dispatch void format(RosettaSegment ele, extension IFormattableDocument document) {
		val extension segmentGrammarAccess = rosettaSegmentAccess
		
		ele.regionFor.assignment(nameAssignment_1)
			.prepend[oneSpace]
	}


	def dispatch void format(Data ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(dataAccess.typeKeyword_0).append(ONE_SPACE)
		ele.regionFor.keyword(dataAccess.extendsKeyword_2_0).append(ONE_SPACE)
		ele.regionFor.keyword(':').prepend(NO_SPACE)
		ele.formatDefinition(document)
		ele.indentInner(document)
		ele.synonyms.forEach[
			prepend[newLine]
			format
		]
		ele.annotations.forEach[
			prepend[newLine]
			format
		]
		ele.attributes.head
			.prepend[setNewLines(2)]
			.format
		ele.attributes.tail.forEach[
			prepend[newLine]
			format
		]
		ele.conditions.forEach[
			prepend[setNewLines(2)]
			format
		]
	}
	
	def dispatch void format(Annotation ele, extension IFormattableDocument document) {
		val extension annotationGrammarAccess = annotationAccess
		
		ele.regionFor.keyword(annotationKeyword_0)
			.append[oneSpace]
		ele.regionFor.keyword(':')
			.prepend[noSpace]
		ele.formatDefinition(document)
		ele.indentInner(document)
		
		val left = ele.regionFor.keyword('[')
		if (left !== null) {
			val right = ele.regionFor.keyword(']')
			left.append[noSpace]
			right.prepend[noSpace]
			singleSpacesUntil(document, left.nextHiddenRegion.nextHiddenRegion, right.previousHiddenRegion)
		}

		ele.attributes.head
			.prepend[setNewLines(2)]
			.format
		ele.attributes.tail.forEach[
			prepend[newLine]
			format
		]
	}

	def dispatch void format(Attribute ele, extension IFormattableDocument document) {
		ele.card.formatCardinality(document)
		ele.indentInner(document)
		ele.regionFor.feature(ROSETTA_TYPED__TYPE)
			.surround[oneSpace]
		ele.formatDefinition(document)
		ele.references.forEach[
			prepend[newLine]
			format
		]
		ele.annotations.forEach[
			prepend[newLine]
			format
		]
		ele.synonyms.forEach[
			prepend[newLine]
			format
		]
	}
	
	private def formatCardinality(RosettaCardinality card, extension IFormattableDocument document) {
		card.regionFor.keyword('(')
			.append[noSpace]
		card.regionFor.keyword('..')
			.surround[noSpace]
		card.regionFor.keyword(')')
			.prepend[noSpace]
	}
	
	private def EObject formatSingleLineAnnotation(EObject annotation, extension IFormattableDocument document) {
		val left = annotation.regionFor.keyword('[')
		val right = annotation.regionFor.keyword(']')
		
		left.append[noSpace]
		right.prepend[noSpace]
		singleSpacesUntil(document, left.nextHiddenRegion.nextHiddenRegion, right.previousHiddenRegion)
		return annotation
	}
	
	def dispatch void format(Condition ele, extension IFormattableDocument document) {
		ele.regionFor.assignment(rosettaNamedAccess.nameAssignment)
			.prepend[oneSpace]
		ele.regionFor.keyword(':')
			.prepend[noSpace]
		ele.formatDefinition(document)
		ele.indentInner(document)
		ele.annotations.forEach[
			prepend[newLine]
			format
		]
		ele.expression
			.prepend[newLine]
			.format
	}
	
	private def RosettaDefinable formatDefinition(RosettaDefinable ele, extension IFormattableDocument document) {
		if (ele.definition !== null) {
			ele.regionFor.keyword('<')
				.prepend[oneSpace]
				.append[noSpace]
			ele.regionFor.keyword('>')
				.prepend[noSpace]
		}
		return ele
	}
	
	def dispatch void format(AnnotationRef ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(annotationRefAccess.leftSquareBracketKeyword_0).append(NO_SPACE)
		ele.regionFor.keyword(annotationRefAccess.rightSquareBracketKeyword_3).prepend(NO_SPACE)
		ele.regionFor.assignment(annotationRefAccess.attributeAssignment_2_0).prepend(ONE_SPACE)
	}
	
	def dispatch void format(Function ele, extension IFormattableDocument document) {
		val extension functionGrammarAccess = functionAccess
		
		ele.regionFor.keyword(funcKeyword_0)
			.append[oneSpace]
			
		if (ele instanceof FunctionDispatch) {
			ele.regionFor.keyword(leftParenthesisKeyword_1_1_2)
				.surround[noSpace]
			ele.regionFor.keyword(colonKeyword_1_1_4)
				.prepend[noSpace]
				.append[oneSpace]
			ele.value.format
			ele.regionFor.keyword(rightParenthesisKeyword_1_1_6)
				.surround[noSpace]
		}
		
		ele.regionFor.keyword(colonKeyword_2)
			.prepend[noSpace]
		ele.formatDefinition(document)
		
		ele.indentInner(document)
		
		ele.references.forEach[
			prepend[newLine]
			format
		]
		ele.annotations.forEach[
			prepend[newLine]
			format
		]
		
		val inputsKW = ele.regionFor.keyword(inputsKeyword_5_0)
		if (inputsKW !== null) {
			inputsKW
				.prepend[newLine]
			val inputsColon = ele.regionFor.keyword(colonKeyword_5_1)
				.prepend[noSpace]
			set(
				inputsColon.nextHiddenRegion,
				ele.inputs.last.nextHiddenRegion,
				[indent]
			)
			ele.inputs.forEach[
				prepend[newLine]
				format
			]
		}
		
		if (ele.output !== null) { // might be null for dispatch functions!
			ele.regionFor.keyword(outputKeyword_6_0)
				.prepend[newLine]
			ele.regionFor.keyword(colonKeyword_6_1)
				.prepend[noSpace]
			set(
				ele.regionFor.keyword(colonKeyword_6_1).nextHiddenRegion,
				ele.output.nextHiddenRegion,
				[indent]
			)
			ele.output
				.prepend[newLine]
				.format
		}
		
		ele.shortcuts.forEach[
			prepend[newLine]
			format
		]
		ele.conditions.forEach[
			prepend[newLine]
			format
		]
		ele.operations.forEach[
			prepend[newLine]
			format
		]
		ele.postConditions.forEach[
			prepend[newLine]
			format
		]
	}
	
	def dispatch void format(RosettaEnumValueReference ele, extension IFormattableDocument document) {
		ele.regionFor.keyword('->').surround[oneSpace]
	}
	
	def dispatch void format(ShortcutDeclaration ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(shortcutDeclarationAccess.aliasKeyword_0)
			.append[oneSpace]
		ele.regionFor.keyword(':')
			.prepend[noSpace]
		ele.formatDefinition(document)
		formatInlineOrMultiline(document, ele,
			[extension doc |
				ele.expression
					.prepend[oneSpace]
					.format
			],
			[extension doc |
				ele.indentInner(doc)
				ele.expression
					.prepend[newLine]
					.format
			]
		)
	}
	
	def dispatch void format(Operation ele, extension IFormattableDocument document) {
		val extension outputOperationGrammarAccess = outputOperationAccess
		
		ele.regionFor.keyword(setKeyword_0_0)
			.append[oneSpace]
		ele.regionFor.keyword(addAddKeyword_0_1_0)
			.append[oneSpace]
		if (ele.path !== null) {
			ele.path.format
		}
		ele.formatDefinition(document)
		
		ele.regionFor.keyword(colonKeyword_3)
			.prepend[noSpace]
		formatInlineOrMultiline(document, ele,
			[extension doc |
				ele.expression
					.prepend[oneSpace]
					.format
			],
			[extension doc |
				ele.indentInner(doc)
				ele.expression
					.prepend[newLine]
					.format
			]
		)
	}
	
	def dispatch void format(Segment ele, extension IFormattableDocument document) {
		ele.regionFor.keyword('->').surround[oneSpace]
		if (ele.next !== null) {
			ele.next.format
		}
	}

	def dispatch void format(RosettaDocReference rosettaRegulatoryReference, extension IFormattableDocument document) {
		val extension rosettaDocReferenceGrammarAccess = rosettaDocReferenceAccess
		
		val left = rosettaRegulatoryReference.regionFor.keyword('[')
		val right = rosettaRegulatoryReference.regionFor.keyword(']')
		
		left.append[noSpace]
		right.prepend[noSpace]
		interior(
			left,
			right,
			[indent]
		)
		singleSpacesUntil(
			document,
			left.nextHiddenRegion.nextHiddenRegion,
			rosettaRegulatoryReference.docReference.nextHiddenRegion
		)
		rosettaRegulatoryReference.rationales.forEach[
			regionFor.keyword(documentRationaleAccess.rationaleKeyword_0_0)
				.prepend[newLine]
				.append[oneSpace]
			regionFor.keyword(documentRationaleAccess.rationale_authorKeyword_1_0)
				.prepend[newLine]
				.append[oneSpace]
		]
		rosettaRegulatoryReference.regionFor.keyword(structured_provisionKeyword_4_0)
			.prepend[newLine]
			.append[oneSpace]
		rosettaRegulatoryReference.regionFor.keyword(provisionKeyword_5_0)
			.prepend[newLine]
			.append[oneSpace]
		rosettaRegulatoryReference.regionFor.keyword(reportedFieldReportedFieldKeyword_6_0)
			.prepend[newLine]
	}

	def dispatch void format(RosettaClassSynonym ele, extension IFormattableDocument document) {
		ele.formatSingleLineAnnotation(document)
	}
	
	def dispatch void format(RosettaSynonym ele, extension IFormattableDocument document) {
		ele.formatSingleLineAnnotation(document)
	}
	
	def dispatch void format(RosettaEnumeration ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(enumerationAccess.enumKeyword_0)
			.append[oneSpace]
		ele.regionFor.keyword(enumerationAccess.colonKeyword_3)
			.prepend[noSpace]
		ele.formatDefinition(document)
		ele.indentInner(document)
		
		ele.synonyms.forEach[
			prepend[newLine]
			format
		]
		ele.enumValues.head
			.prepend[setNewLines(2)]
			.format
		ele.enumValues.tail.forEach[
			prepend[newLine]
			format
		]
	}

	def dispatch void format(RosettaEnumValue rosettaEnumValue, extension IFormattableDocument document) {
		rosettaEnumValue
			.formatDefinition(document)
			.indentInner(document)
		rosettaEnumValue.enumSynonyms.forEach[
			prepend[newLine]
			format
		]
	}

	def dispatch void format(RosettaEnumSynonym rosettaEnumSynonym, extension IFormattableDocument document) {		
		formatSingleLineAnnotation(rosettaEnumSynonym, document)
	}
		
	def dispatch void format(RosettaExternalSynonym externalSynonym, extension IFormattableDocument document) {
		formatSingleLineAnnotation(externalSynonym, document)
	}

	def dispatch void format(RosettaExpression ele, extension IFormattableDocument document) {
		expressionFormatter.formatExpression(ele, document)
	}
	
	def dispatch void format(RosettaBlueprint ele, extension IFormattableDocument document) {
		val extension ruleGrammarAccess = rosettaBlueprintAccess
		
		val firstKeyword = ele.regionFor.keyword(reportingKeyword_0_0)
			?: ele.regionFor.keyword(eligibilityKeyword_0_1)
		
		firstKeyword
			.append[oneSpace]
		ele.regionFor.keyword(ruleKeyword_1)
			.append[oneSpace]
		ele.regionFor.keyword(colonKeyword_3)
			.prepend[noSpace]
			.append[oneSpace]
		ele.formatDefinition(document)
		
		ele.indentInner(document)
		
		ele.references.forEach[ // TODO: format references
			prepend[newLine]
			format
		]
		
		ele.nodes
			.prepend[newLine]
			.format
	}
	
	def dispatch void format(BlueprintNodeExp ele, extension IFormattableDocument document) {
		expressionFormatter.formatRuleExpression(ele, document)
	}
	
	def dispatch void format(RosettaSynonymSource synonymSource, extension IFormattableDocument document) {
		val extension synonymSourceGrammarAccess = rosettaSynonymSourceAccess
		
		synonymSource.regionFor.keyword(sourceKeyword_1)
			.surround[oneSpace]
	}

	def dispatch void format(RosettaExternalSynonymSource externalSynonymSource, extension IFormattableDocument document) {
		val extension externalSynonymSourceGrammarAccess = rosettaExternalSynonymSourceAccess
		
		externalSynonymSource.regionFor.keyword(sourceKeyword_1)
			.surround[oneSpace]
		externalSynonymSource.regionFor.keyword(extendsKeyword_3_0)
			.surround[oneSpace]
		
		indentedBraces(externalSynonymSource, document)
		externalSynonymSource.externalClasses.head
			.prepend[newLine]
		externalSynonymSource.externalClasses.tail.forEach[
			prepend[setNewLines(2)]
		]
		externalSynonymSource.externalClasses.forEach[
			format
		]
		
		val enumsKeyword = externalSynonymSource.regionFor.keyword(enumsKeyword_6_0)
		if (enumsKeyword !== null) {
			if (externalSynonymSource.externalClasses.empty) {
				enumsKeyword.prepend[newLine]
			} else {
				enumsKeyword.prepend[setNewLines(2)]
			}
			externalSynonymSource.externalEnums.forEach[
				prepend[setNewLines(2)]
				format
			]
		}
	}

	def dispatch void format(RosettaExternalClass externalClass, extension IFormattableDocument document) {
		externalClass.regionFor.keyword(':').prepend[noSpace]
		externalClass.indentInner(document)
		externalClass.regularAttributes.forEach[
			prepend[newLine]
			format
		]
	}

	def dispatch void format(RosettaExternalEnum externalEnum, extension IFormattableDocument document) {
		externalEnum.regionFor.keyword(':').prepend[noSpace]
		externalEnum.indentInner(document)
		externalEnum.regularValues.forEach[
			prepend[newLine]
			format
		]
	}

	def dispatch void format(RosettaExternalRegularAttribute externalRegularAttribute, extension IFormattableDocument document) {
		externalRegularAttribute.regionFor.keyword('+')
			.append[oneSpace]
		externalRegularAttribute.regionFor.keyword('-')
			.append[oneSpace]
		externalRegularAttribute.indentInner(document)
		externalRegularAttribute.externalSynonyms.forEach[
			prepend[newLine]
			format
		]
	}
	
	def dispatch void format(RosettaExternalEnumValue externalEnumValue, extension IFormattableDocument document) {
		externalEnumValue.regionFor.keyword('+')
			.append[oneSpace]
		externalEnumValue.regionFor.keyword('-')
			.append[oneSpace]
		externalEnumValue.indentInner(document)
		externalEnumValue.externalEnumSynonyms.forEach[
			prepend[newLine]
			format
		]
	}

	def void indentedBraces(EObject eObject, extension IFormattableDocument document) {
		val lcurly = eObject.regionFor.keyword('{').prepend[newLine]
		val rcurly = eObject.regionFor.keyword('}').prepend[newLine]
		interior(lcurly, rcurly)[indent]
	}

	def void surroundWithOneSpace(EObject eObject, extension IFormattableDocument document) {
		for (ISemanticRegion w : eObject.allSemanticRegions) {
			w.surround[oneSpace];
		}
	}

	def void appendWithOneSpace(EObject eObject, extension IFormattableDocument document) {
		eObject.regionFor.keyword(',').append[oneSpace]
	}
}
