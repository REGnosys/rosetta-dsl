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
import com.regnosys.rosetta.rosetta.simple.Constraint
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Definable
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.rosetta.simple.ShortcutDeclaration
import com.regnosys.rosetta.services.RosettaGrammarAccess
import com.rosetta.model.lib.annotations.RosettaChoiceRule
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.IHiddenRegionFormatter
import org.eclipse.xtext.formatting2.regionaccess.ISemanticRegion
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1
import org.eclipse.xtext.formatting2.FormatterRequest

import static com.regnosys.rosetta.rosetta.RosettaPackage.Literals.*

class RosettaFormatter extends AbstractFormatter2 {
	
	static val Procedure1<? super IHiddenRegionFormatter> NO_SPACE = [noSpace]
	static val Procedure1<? super IHiddenRegionFormatter> NO_SPACE_PRESERVE_NEW_LINE = [setNewLines(0, 0, 1);noSpace]
	static val Procedure1<? super IHiddenRegionFormatter> NO_SPACE_LOW_PRIO = [noSpace; lowPriority]
	static val Procedure1<? super IHiddenRegionFormatter> ONE_SPACE = [oneSpace]
	static val Procedure1<? super IHiddenRegionFormatter> ONE_SPACE_LOW_PRIO = [oneSpace; lowPriority]
	static val Procedure1<? super IHiddenRegionFormatter> ONE_SPACE_PRESERVE_NEWLINE = [setNewLines(0, 0, 1); oneSpace]
	static val Procedure1<? super IHiddenRegionFormatter> NEW_LINE = [setNewLines(1, 1, 2)]
	
	static val Procedure1<? super IHiddenRegionFormatter> NEW_ROOT_ELEMENT = [setNewLines(2, 2, 3);highPriority]
	
	static val Procedure1<? super IHiddenRegionFormatter> NEW_LINE_LOW_PRIO = [lowPriority; setNewLines(1, 1, 2)]
	static val Procedure1<? super IHiddenRegionFormatter> INDENT = [indent]
	
	@Inject extension RosettaGrammarAccess
	@Inject RosettaExpressionFormatter expressionFormatter
	
	protected override void initialize(FormatterRequest request) {
		super.initialize(request)
		expressionFormatter.initialize(request)
	}
	
	def dispatch void format(RosettaModel rosettaModel, extension IFormattableDocument document) {
		val extension modelGrammarAccess = rosettaModelAccess
		
		rosettaModel.regionFor.keyword(namespaceKeyword_0)
			.prepend[noSpace]
			.append[oneSpace]
		rosettaModel.regionFor.keyword(versionKeyword_3_0).prepend[newLine]
		rosettaModel.elements.forEach[it.format(document)]
	}


	def dispatch void format(Data ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(dataAccess.typeKeyword_0).append(ONE_SPACE).prepend(NEW_ROOT_ELEMENT)
		ele.regionFor.keyword(dataAccess.extendsKeyword_2_0).append(ONE_SPACE)
		ele.regionFor.keyword(':').prepend(NO_SPACE).append(ONE_SPACE)
		ele.formatDefinition(document)
		val eleEnd = ele.nextHiddenRegion
		set(
			ele.regionFor.keyword(':').nextHiddenRegion,
			eleEnd,
			INDENT
		)
		ele.synonyms.forEach[
			format
		]
		ele.annotations.forEach[
			prepend(NEW_LINE_LOW_PRIO)
			format
		]
		ele.attributes.forEach[
			prepend(NEW_LINE_LOW_PRIO)
			format
		]
		ele.conditions.forEach[
			prepend(NEW_LINE_LOW_PRIO)
			format
		]
		set(eleEnd, NEW_LINE_LOW_PRIO)
	}

	def dispatch void format(Attribute ele, extension IFormattableDocument document) {
		ele.indentInner(document)
		ele.formatDefinition(document)
		ele.annotations.forEach[
			prepend(NEW_LINE_LOW_PRIO)
			format
		]
		ele.synonyms.forEach[
			formatAttributeSynonym(document)
		]
	}
	
	/**
	 * Use default format() when isEvent, isProduct and Enum formatting is implemented
	 */
	private def formatAttributeSynonym(RosettaSynonym ele,  extension IFormattableDocument document) {
		ele.prepend(NEW_LINE_LOW_PRIO).append(NEW_LINE_LOW_PRIO)
	}
	
	def dispatch void format(Condition ele, extension IFormattableDocument document) {
		
		ele.annotations.forEach[format]
		ele.regionFor.keyword(':').append(ONE_SPACE_PRESERVE_NEWLINE)
		ele.formatDefinition(document)
		val eleEnd = ele.nextHiddenRegion
		set(
			ele.regionFor.keyword(':').nextHiddenRegion,
			eleEnd,
			INDENT
		)
		ele.constraint.format
		ele.expression.format
	}
	
	private def void formatDefinition(Definable ele, extension IFormattableDocument document) {
		if (ele.definition !== null)
			ele.regionFor.keyword('>').append(NEW_LINE)
	}
	
	def dispatch void format(Constraint ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(necessityAccess.requiredRequiredKeyword_1_0).prepend(ONE_SPACE_PRESERVE_NEWLINE)
		ele.regionFor.keyword(necessityAccess.optionalOptionalKeyword_0_0).prepend(ONE_SPACE_PRESERVE_NEWLINE)
		ele.regionFor.keyword(
			constraintAccess.choiceKeyword_1
		).surround(ONE_SPACE)
		
		ele.allRegionsFor.keyword(',').prepend(NO_SPACE_LOW_PRIO).append(ONE_SPACE_PRESERVE_NEWLINE)
	}
	
	def dispatch void format(AnnotationRef ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(annotationRefAccess.leftSquareBracketKeyword_0).append(NO_SPACE)
		ele.regionFor.keyword(annotationRefAccess.rightSquareBracketKeyword_3).prepend(NO_SPACE)
		ele.regionFor.assignment(annotationRefAccess.attributeAssignment_2_0).prepend(ONE_SPACE)
	}
	
	def dispatch void format(Function ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(functionAccess.funcKeyword_0).append(ONE_SPACE).prepend(NEW_ROOT_ELEMENT)
		ele.regionFor.keyword(functionAccess.colonKeyword_2).prepend(NO_SPACE).append(ONE_SPACE)
		ele.formatDefinition(document)
		
		ele.indentInner(document)
		ele.append(NEW_LINE_LOW_PRIO)
		
		ele.annotations.forEach[
			prepend(NEW_LINE)prepend(NEW_LINE)
			format
		]
		
		val inputsKW = ele.regionFor.keyword(functionAccess.inputsKeyword_5_0)
		if (inputsKW !== null) {
			inputsKW.prepend(NEW_LINE).append(NO_SPACE)
			val inputsColon = ele.regionFor.keyword(functionAccess.colonKeyword_5_1).prepend(NO_SPACE).append(ONE_SPACE)
			if (ele.inputs.size <= 1) {
				inputsColon.append(ONE_SPACE_PRESERVE_NEWLINE)
			} else {
				inputsColon.append(NEW_LINE)
			}
			set(
				inputsColon.nextHiddenRegion,
				ele.inputs.last.nextHiddenRegion,
				[indent]
			)
			ele.inputs.forEach[
				prepend(NEW_LINE_LOW_PRIO)
				format
			]
		}
		
		ele.regionFor.keyword(functionAccess.outputKeyword_6_0).prepend(NEW_LINE).append(NO_SPACE)
		ele.regionFor.keyword(functionAccess.colonKeyword_6_1).prepend(NO_SPACE).append(ONE_SPACE_PRESERVE_NEWLINE)
		if(ele.output !== null) {
			set(
				ele.regionFor.keyword(functionAccess.colonKeyword_6_1).nextHiddenRegion,
				ele.output.nextHiddenRegion,
				INDENT
			)
			ele.output.format
		}
		
		ele.shortcuts.forEach[
			prepend(NEW_LINE)
			format
		]
		ele.conditions.forEach[
			prepend(NEW_LINE)
			format
		]
		ele.operations.forEach[
			prepend(NEW_LINE)
			format
		]
		ele.postConditions.forEach[
			prepend(NEW_LINE)
			format
		]
		
	}
	
	def dispatch void format(ShortcutDeclaration ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(shortcutDeclarationAccess.aliasKeyword_0).append(ONE_SPACE)
		ele.regionFor.keyword(':').prepend(NO_SPACE).append(ONE_SPACE_PRESERVE_NEWLINE)
		ele.formatDefinition(document)
		val eleEnd = ele.nextHiddenRegion
		set(
			ele.regionFor.keyword(':').nextHiddenRegion,
			eleEnd,
			INDENT
		)
		ele.expression.format
	}
	
	def dispatch void format(Operation ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(':').prepend(NO_SPACE).append(ONE_SPACE_PRESERVE_NEWLINE)
		
		ele.expression.surround(INDENT)
		ele.expression.format
				
		// Format parentheses
		ele.allRegionsFor.keywords(rosettaCalcPrimaryAccess.leftParenthesisKeyword_3_0)
			.forEach[append(NO_SPACE_PRESERVE_NEW_LINE)]
	    ele.allRegionsFor.keywords(rosettaCalcPrimaryAccess.rightParenthesisKeyword_3_2)
			.forEach[prepend(NO_SPACE_PRESERVE_NEW_LINE)]
	}

	def dispatch void format(RosettaDocReference rosettaRegulatoryReference,
		extension IFormattableDocument document) {
		rosettaRegulatoryReference.prepend[newLine].surround[indent]
	}

	def dispatch void format(RosettaClassSynonym ele, extension IFormattableDocument document) {
		ele.prepend(NEW_LINE_LOW_PRIO).append(NEW_LINE_LOW_PRIO)
	}
	
	def dispatch void format(RosettaSynonym rosettaSynonym, extension IFormattableDocument document) {
		singleIndentedLine(rosettaSynonym, document)
	}
	
	def dispatch void format(RosettaEnumeration ele, extension IFormattableDocument document) {
		ele.regionFor.keyword(enumerationAccess.enumKeyword_0).prepend(NEW_ROOT_ELEMENT)
		val eleEnd = ele.nextHiddenRegion
		set(
			ele.regionFor.keyword(enumerationAccess.enumKeyword_0).nextHiddenRegion,
			eleEnd,
			INDENT
		)
		ele.synonyms.forEach[formatAttributeSynonym(document)]
		ele.enumValues.forEach[ format ]
	}

	def dispatch void format(RosettaEnumValue rosettaEnumValue, extension IFormattableDocument document) {
		rosettaEnumValue.prepend(NEW_LINE)
		rosettaEnumValue.enumSynonyms.forEach[
			format
		]
	}

	def dispatch void format(RosettaEnumSynonym rosettaEnumSynonym, extension IFormattableDocument document) {
		rosettaEnumSynonym.prepend[newLine].surround[indent]
	}

	def dispatch void format(RosettaExpression ele, extension IFormattableDocument document) {
		expressionFormatter.formatExpression(ele, document)
	}

	def dispatch void format(RosettaChoiceRule rosettaChoiceRule, extension IFormattableDocument document) {
	}

	def dispatch void format(RosettaExternalSynonymSource externalSynonymSource,
		extension IFormattableDocument document) {
		indentedBraces(externalSynonymSource, document)
		externalSynonymSource.externalClasses.forEach[it.format(document)]
		externalSynonymSource.externalEnums.forEach[it.format(document)]
	}

	def dispatch void format(RosettaExternalClass externalClass, extension IFormattableDocument document) {
		externalClass.regionFor.keyword(':').prepend[noSpace]
		externalClass.prepend[lowPriority; setNewLines(2)]
		externalClass.regularAttributes.forEach[it.format(document)]
	}

	def dispatch void format(RosettaExternalEnum externalEnum, extension IFormattableDocument document) {
		externalEnum.regionFor.keyword(':').prepend[noSpace]
		externalEnum.prepend[lowPriority; setNewLines(2)]
		externalEnum.regularValues.forEach[it.format(document)]
	}

	def dispatch void format(RosettaExternalRegularAttribute externalRegularAttribute,
		extension IFormattableDocument document) {
		externalRegularAttribute.regionFor.keyword('+').append[oneSpace].prepend[newLine]
		externalRegularAttribute.surround[indent]
		externalRegularAttribute.externalSynonyms.forEach[it.format(document)]
	}
	
	def dispatch void format(RosettaExternalEnumValue externalEnumValue,
		extension IFormattableDocument document) {
		externalEnumValue.regionFor.keyword('+').append[oneSpace].prepend[newLine]
		externalEnumValue.surround[indent]
		externalEnumValue.externalEnumSynonyms.forEach[it.format(document)]
	}
	

	def dispatch void format(RosettaExternalSynonym externalSynonym, extension IFormattableDocument document) {
		externalSynonym.prepend[newLine].surround[indent]
	}

	def void indentedBraces(EObject eObject, extension IFormattableDocument document) {
		val lcurly = eObject.regionFor.keyword('{').prepend[newLine].append[newLine]
		val rcurly = eObject.regionFor.keyword('}').prepend[newLine].append[setNewLines(2)]
		interior(lcurly, rcurly)[highPriority; indent]
	}

	private def void singleIndentedLine(EObject eObject, extension IFormattableDocument document) {
		eObject.prepend(NEW_LINE_LOW_PRIO).append(NEW_LINE_LOW_PRIO).surround[indent]
	}

	def void surroundWithOneSpace(EObject eObject, extension IFormattableDocument document) {
		for (ISemanticRegion w : eObject.allSemanticRegions) {
			w.surround[oneSpace];
		}
	}

	def void appendWithOneSpace(EObject eObject, extension IFormattableDocument document) {
		eObject.regionFor.keyword(',').append[oneSpace]
	}
	
	private def void indentInner(EObject obj, extension IFormattableDocument document) {
		set(
			obj.previousHiddenRegion.nextHiddenRegion,
			obj.nextHiddenRegion,
			[indent]
		)
	}
}
