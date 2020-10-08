package com.regnosys.rosetta.generator.util

import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.generator.object.ExpandedAttribute
import com.regnosys.rosetta.generator.object.ExpandedSynonym
import com.regnosys.rosetta.generator.object.ExpandedSynonymValue
import com.regnosys.rosetta.generator.object.ExpandedType
import com.regnosys.rosetta.rosetta.RosettaCalculationType
import com.regnosys.rosetta.rosetta.RosettaClassSynonym
import com.regnosys.rosetta.rosetta.RosettaEnumSynonym
import com.regnosys.rosetta.rosetta.RosettaEnumValue
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaExternalClass
import com.regnosys.rosetta.rosetta.RosettaExternalClassSynonym
import com.regnosys.rosetta.rosetta.RosettaExternalRegularAttribute
import com.regnosys.rosetta.rosetta.RosettaExternalSynonym
import com.regnosys.rosetta.rosetta.RosettaExternalSynonymSource
import com.regnosys.rosetta.rosetta.RosettaFactory
import com.regnosys.rosetta.rosetta.RosettaMetaType
import com.regnosys.rosetta.rosetta.RosettaQualifiedType
import com.regnosys.rosetta.rosetta.RosettaRootElement
import com.regnosys.rosetta.rosetta.RosettaSynonym
import com.regnosys.rosetta.rosetta.RosettaSynonymBase
import com.regnosys.rosetta.rosetta.RosettaSynonymSource
import com.regnosys.rosetta.rosetta.RosettaSynonymValueBase
import com.regnosys.rosetta.rosetta.RosettaType
import com.regnosys.rosetta.rosetta.RosettaTypedFeature
import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.scoping.RosettaScopeProvider
import java.util.ArrayList
import java.util.Collections
import java.util.List

class RosettaAttributeExtensions {

	static def boolean cardinalityIsSingleValue(ExpandedAttribute attribute) {
		attribute.sup === 1
	}
	
	static def boolean cardinalityIsListValue(ExpandedAttribute attribute) {
		attribute.cardinalityIsSingleValue != true
	}
	
	static def List<ExpandedAttribute> getExpandedAttributes(Data data, boolean sort) {
		val attrs = (data.attributes.map[toExpandedAttribute()].toList + data.additionalAttributes)
		return if(sort)attrs.sortBy[ExpandedAttribute a|a.name] else attrs.toList
	}
	
	dispatch static def List<ExpandedAttribute> getExpandedAttributes(Data data) {
		data.getExpandedAttributes(true)
	}
	
	private static def List<ExpandedAttribute> additionalAttributes(Data data) {
		val res = newArrayList
		val rosExt = new RosettaExtensions // Can't inject as used in rosetta-translate and daml directly
		if(rosExt.hasKeyedAnnotation(data)){
			res.add(new ExpandedAttribute(
				'meta',
				data.name,
				provideMetaFieldsType(data),
				null,
				false,
				0,
				1,
				false,
				emptyList,
				"",
				false,
				false,
				false,
				emptyList
			))
		}
		return res
	}
	
	public static val METAFIELDS_CLASS_NAME = 'MetaFields'
	public static val META_AND_TEMPLATE_FIELDS_CLASS_NAME = 'MetaAndTemplateFields'
	
	private static def ExpandedType provideMetaFieldsType(Data data) {
		val rosModel = RosettaFactory.eINSTANCE.createRosettaModel()
		rosModel.name = RosettaScopeProvider.LIB_NAMESPACE
		val rosExt = new RosettaExtensions // Can't inject as used in rosetta-translate and daml directly
		val name = if (rosExt.hasTemplateAnnotation(data)) META_AND_TEMPLATE_FIELDS_CLASS_NAME else METAFIELDS_CLASS_NAME
		return new ExpandedType(rosModel, name, true, false, false)
	}

	// used in translate project
	@SuppressWarnings("unused")
	static private def ExpandedType provideStringType(RosettaRootElement ctx) {
		return new ExpandedType(ctx.model, 'string', false, false, false)
	}
	
	dispatch static def List<ExpandedAttribute> getExpandedAttributes(RosettaEnumeration rosettaEnum) {
		rosettaEnum.enumValues.map[expandedEnumAttribute]
	}
	
	def static ExpandedAttribute expandedEnumAttribute(RosettaEnumValue value) {
		new ExpandedAttribute(value.name,value.enumeration.name, null, null, false, 0,0, false, value.enumSynonyms.map[toExpandedSynonym], 
			value.definition, false, true, false, Collections.emptyList
		)
	}
	
	def static ExpandedSynonym toExpandedSynonym(RosettaEnumSynonym syn) {
		new ExpandedSynonym(syn.sources, Collections.singletonList(new ExpandedSynonymValue(syn.synonymValue, null, 0, false)), newArrayList, Collections.emptyList, null, null,
			null, syn.patternMatch, syn.patternReplace
		)
	}

	static def boolean isList(ExpandedAttribute a) {
		return a.cardinalityIsListValue
	}

	static def toRosettaExpandedSynonym(Attribute attr, int index) {
		attr.synonyms.filter[body.metaValues.size > index].map[
			s|new ExpandedSynonym(s.sources, s.body.values?.map[metaSynValue(s.body.metaValues.get(index))
				//new ExpandedSynonymValue(s.metaValues.get(index), path+"."+value, maps, true)
			].toList, s.body.hints, s.body.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], s.body.mappingLogic, 
				s.body.mapper, s.body.format, s.body.patternMatch, s.body.patternReplace)
		]
		.filter[!values.isEmpty]
		.toList
	}

	static def toRosettaExpandedSynonym(List<RosettaSynonymSource> sources, List<RosettaExternalSynonym> externalSynonyms, int index) {		
		externalSynonyms.filter[body.metaValues.size > index].map[
			s|new ExpandedSynonym(sources, s.body.values?.map[metaSynValue(s.body.metaValues.get(index))
				//new ExpandedSynonymValue(s.metaValues.get(index), path+"."+value, maps, true)
			].toList, s.body.hints, s.body.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], s.body.mappingLogic, 
				s.body.mapper, s.body.format, s.body.patternMatch, s.body.patternReplace)
		]
		.filter[!values.isEmpty]
		.toList
	}

	static def toExpandedAttribute(Attribute attr) {
		val metas = <ExpandedAttribute>newArrayList
		attr.annotations.forEach [ annoRef, i |
			val annoAttr = annoRef?.attribute
			if(annoAttr !== null && annoAttr.type !== null) {
				metas.add(new ExpandedAttribute(
					annoAttr.name,
					annoRef.annotation.name,
					annoAttr.type.toExpandedType,
					annoAttr.type,
					annoAttr.override,
					0,
					1,
					false,
					attr.toRosettaExpandedSynonym(i),
					attr.definition,
					false,
					false,
					false,
					Collections.emptyList
				))
			}
		]
		new ExpandedAttribute(
			attr.name,
			(attr.eContainer as RosettaType).name,
			attr.type.toExpandedType,
			attr.type,
			attr.override,
			attr.card.inf,
			attr.card.sup,
			attr.card.unbounded,
			attr.synonyms.toRosettaExpandedSynonyms(-1),
			attr.definition,
			attr.calculation,
			attr.isEnumeration,
			attr.qualified,
			metas
		)
	}
	
	static def ExpandedType toExpandedType(RosettaType type) {
		return new ExpandedType(type.model, type.name,type instanceof Data, type instanceof RosettaEnumeration, type instanceof RosettaMetaType)
	}
	
	static def toRosettaExpandedSynonyms(List<RosettaSynonym> synonyms, int meta) {
		if (meta<0) {
			synonyms.map[new ExpandedSynonym(sources, body.values?.map[new ExpandedSynonymValue(name, path, maps, false)], body.hints, 
				body.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], body.mappingLogic, 
				body.mapper, body.format, body.patternMatch, body.patternReplace
			)]
		} else {
			synonyms.filter[body.metaValues.size>meta]
			.map[s|new ExpandedSynonym(s.sources, s.body.values?.map[metaSynValue(s.body.metaValues.get(meta))], s.body.hints, 
				s.body.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], s.body.mappingLogic, 
				s.body.mapper, s.body.format, s.body.patternMatch, s.body.patternReplace
			)]
			.toList
		}
		
	}
	
	def static metaSynValue(RosettaSynonymValueBase value, String meta) {
		val path = if (value.path===null) value.name else value.path+"->"+value.name
		val name = meta
		return new ExpandedSynonymValue(name, path, value.maps, true)
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaSynonymBase synonym) {
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaSynonym syn) {
		new ExpandedSynonym(syn.sources, syn.body.values?.map[new ExpandedSynonymValue(name, path, maps, false)], 
			syn.body.hints, syn.body.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], syn.body.mappingLogic, 
			syn.body.mapper, syn.body.format, syn.body.patternMatch, syn.body.patternReplace
		)
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaExternalSynonym syn) {
		val externalAttr = syn.eContainer as RosettaExternalRegularAttribute;
		val externalClass = externalAttr.eContainer as RosettaExternalClass
		val externalSynonymSource = externalClass.eContainer as RosettaExternalSynonymSource
		val superSynonym = externalSynonymSource.superSynonym;
		
		val sources = new ArrayList
		sources.add(externalSynonymSource)
		if  (superSynonym !== null) {
			sources.add(superSynonym)
		}
		
		new ExpandedSynonym(sources, syn.body.values?.map[new ExpandedSynonymValue(name, path, maps, false)], syn.body.hints, 
			syn.body.metaValues.map[new ExpandedSynonymValue(it, null, 1, true)], syn.body.mappingLogic, syn.body.mapper,
			syn.body.format, syn.body.patternMatch, syn.body.patternReplace
		)
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaExternalClassSynonym syn) {
		val synVals = if (syn.value===null) Collections.emptyList else newArrayList(new ExpandedSynonymValue(syn.value.name, syn.value.path, syn.value.maps, false))
		val synMetaVals = if (syn.metaValue!==null) newArrayList(new ExpandedSynonymValue(syn.metaValue.name, syn.metaValue.path, syn.metaValue.maps, true)) else Collections.emptyList
		new ExpandedSynonym(syn.sources, synVals, newArrayList, synMetaVals, null, null, null, null, null)	
	}
	
	static dispatch def toRosettaExpandedSynonym(RosettaClassSynonym syn) {
		val synVals = if (syn.value===null) Collections.emptyList else newArrayList(new ExpandedSynonymValue(syn.value.name, syn.value.path, syn.value.maps, false))
		val synMetaVals = if (syn.metaValue!==null) newArrayList(new ExpandedSynonymValue(syn.metaValue.name, syn.metaValue.path, syn.metaValue.maps, true)) else Collections.emptyList
		new ExpandedSynonym(syn.sources, synVals, newArrayList, synMetaVals, null, null, null, null, null)
	}

	private def static boolean isCalculation(RosettaTypedFeature a) {
		return a.type instanceof RosettaCalculationType
	}

	private def static boolean isEnumeration(RosettaTypedFeature a) {
		return a.type instanceof RosettaEnumeration
	}

	private def static boolean isQualified(RosettaTypedFeature a) {
		return a.type instanceof RosettaQualifiedType
	}
	
}