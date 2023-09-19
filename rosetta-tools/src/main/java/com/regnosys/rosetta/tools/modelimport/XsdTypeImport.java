package com.regnosys.rosetta.tools.modelimport;

import java.util.List;
import java.util.Optional;
import java.util.stream.Stream;

import javax.inject.Inject;

import org.xmlet.xsdparser.xsdelements.XsdAttribute;
import org.xmlet.xsdparser.xsdelements.XsdComplexType;
import org.xmlet.xsdparser.xsdelements.XsdElement;
import org.xmlet.xsdparser.xsdelements.XsdExtension;
import org.xmlet.xsdparser.xsdelements.XsdSimpleContent;
import org.xmlet.xsdparser.xsdelements.XsdSimpleType;
import org.xmlet.xsdparser.xsdelements.elementswrapper.ReferenceBase;
import org.xmlet.xsdparser.xsdelements.enums.UsageEnum;
import org.xmlet.xsdparser.xsdelements.visitors.AttributesVisitor;

import com.regnosys.rosetta.rosetta.RegulatoryDocumentReference;
import com.regnosys.rosetta.rosetta.RosettaBody;
import com.regnosys.rosetta.rosetta.RosettaCardinality;
import com.regnosys.rosetta.rosetta.RosettaCorpus;
import com.regnosys.rosetta.rosetta.RosettaDocReference;
import com.regnosys.rosetta.rosetta.RosettaFactory;
import com.regnosys.rosetta.rosetta.RosettaSegment;
import com.regnosys.rosetta.rosetta.RosettaSegmentRef;
import com.regnosys.rosetta.rosetta.RosettaType;
import com.regnosys.rosetta.rosetta.TypeCall;
import com.regnosys.rosetta.rosetta.simple.Attribute;
import com.regnosys.rosetta.rosetta.simple.Data;
import com.regnosys.rosetta.rosetta.simple.SimpleFactory;

public class XsdTypeImport extends AbstractXsdImport<XsdComplexType, Data> {
	public final String UNBOUNDED = "unbounded";
	public final String SIMPLE_EXTENSION_ATTRIBUTE_NAME = "value";

	private final XsdUtil util;
	
	@Inject
	public XsdTypeImport(XsdUtil util) {
		super(XsdComplexType.class);
		this.util = util;
	}
	
	private Stream<XsdElement> getTypedXsdElements(XsdComplexType xsdType) {
		return Optional.of(xsdType)
				.map(XsdComplexType::getElements).stream()
				.flatMap(List::stream)
				.map(ReferenceBase::getElement)
				.filter(XsdElement.class::isInstance)
				.map(XsdElement.class::cast)
				.filter(xsdElement -> xsdElement.getType() != null);
	}
	private Stream<XsdAttribute> getTypedXsdAttributes(XsdComplexType xsdType) {
		return Optional.of(xsdType)
				.map(XsdComplexType::getSimpleContent)
				.map(XsdSimpleContent::getXsdExtension)
				.map(XsdExtension::getVisitor)
				.filter(v -> v instanceof AttributesVisitor)
				.map(v -> (AttributesVisitor)v)
				.map(AttributesVisitor::getAllAttributes).stream()
				.flatMap(List::stream)
				.filter(xsdElement -> xsdElement.getType() != null);
	}
	private Optional<XsdSimpleType> getBaseSimpleType(XsdComplexType xsdType) {
		return Optional.of(xsdType)
				.map(XsdComplexType::getSimpleContent)
				.map(XsdSimpleContent::getXsdExtension)
				.map(XsdExtension::getBaseAsSimpleType);
	}

	@Override
	public Data registerType(XsdComplexType xsdType, RosettaXsdMapping xsdMapping, GenerationProperties properties) {
		Data data = SimpleFactory.eINSTANCE.createData();
		data.setName(xsdType.getName());
		util.extractDocs(xsdType).ifPresent(data::setDefinition);
		xsdMapping.registerComplexType(xsdType, data);
		
		// If the complex type extends a simple type, simulate this
		// by adding a `value` attribute of the corresponding type.
		if (getBaseSimpleType(xsdType).isPresent()) {
			data.getAttributes().add(
				registerValueAttribute(xsdType, xsdMapping)
			);
		}
		
		// Map XSD elements to Rosetta attributes.
		getTypedXsdElements(xsdType)
			.map(element -> registerAttribute(element, xsdMapping))
			.forEach(data.getAttributes()::add);
		
		// Map XSD attributes to Rosetta attributes.
		getTypedXsdAttributes(xsdType)
			.map(attribute -> registerAttribute(attribute, xsdMapping))
			.forEach(data.getAttributes()::add);
		
		return data;
	}

	@Override
	public void completeType(XsdComplexType xsdType, RosettaXsdMapping xsdMapping) {
		Data data = xsdMapping.getRosettaTypeFromComplex(xsdType);
		
		// Add supertype
		Optional.of(xsdType)
			.map(XsdComplexType::getSimpleContent)
			.map(XsdSimpleContent::getXsdExtension)
			.map(XsdExtension::getBaseAsComplexType)
			.ifPresent(base -> {
				Data superType = xsdMapping.getRosettaTypeFromComplex(base);
				data.setSuperType(superType);
			});
		
		// If the complex type extends a simple type, add the corresponding type
		// to the dedicated `value` attribute.
		Optional<XsdSimpleType> baseSimpleType = getBaseSimpleType(xsdType);
		if (baseSimpleType.isPresent()) {
			Attribute attr = xsdMapping.getAttribute(xsdType);
			TypeCall call = attr.getTypeCall();
			RosettaType rosettaType = xsdMapping.getRosettaType(baseSimpleType.get());
			call.setType(rosettaType);
		}
		
		// Add types to attributes based on XSD elements.
		getTypedXsdElements(xsdType)
			.forEach(element -> {
				Attribute attr = xsdMapping.getAttribute(element);
				TypeCall call = attr.getTypeCall();
				RosettaType rosettaType = Optional.of(element)
						.map(XsdElement::getTypeAsXsd)
						.map(xsdMapping::getRosettaType)
						.get();
				call.setType(rosettaType);
			});
		
		// Add types to attributes based on XSD elements.
		getTypedXsdAttributes(xsdType)
			.forEach(element -> {
				Attribute attr = xsdMapping.getAttribute(element);
				TypeCall call = attr.getTypeCall();
				RosettaType rosettaType = Optional.of(element)
						.map(XsdAttribute::getXsdSimpleType)
						.map(xsdMapping::getRosettaType)
						.get();
				call.setType(rosettaType);
			});
	}
	
	private Attribute registerAttribute(XsdElement xsdElement, RosettaXsdMapping xsdMapping) {
		Attribute attribute = SimpleFactory.eINSTANCE.createAttribute();

		// definition
		util.extractDocs(xsdElement).ifPresent(attribute::setDefinition);

		// name
		attribute.setName(util.allFirstLowerIfNotAbbrevation(xsdElement.getName()));
		
		// type call
		TypeCall typeCall = RosettaFactory.eINSTANCE.createTypeCall();
		attribute.setTypeCall(typeCall);

		// cardinality
		RosettaCardinality rosettaCardinality = RosettaFactory.eINSTANCE.createRosettaCardinality();
		rosettaCardinality.setInf(xsdElement.getMinOccurs());
		if (xsdElement.getMaxOccurs().equals(UNBOUNDED)) {
			rosettaCardinality.setUnbounded(true);
		} else {
			rosettaCardinality.setSup(Integer.parseInt(xsdElement.getMaxOccurs()));
		}
		attribute.setCard(rosettaCardinality);

		// docReference
//		RosettaBody body = typeMappings.getBody();
//		RosettaCorpus corpus = typeMappings.getCorpus();
//		RosettaSegment segment = typeMappings.getSegment();
//		Optional.ofNullable(element.getTypeAsSimpleType())
//			.map(xsdName -> createRosettaDocReference(xsdName.getName(), body, corpus, segment, util.extractDocs(xsdName)))
//			.ifPresent(attribute.getReferences()::add);
		
		xsdMapping.registerAttribute(xsdElement, attribute);
		
		return attribute;
	}
	private Attribute registerAttribute(XsdAttribute xsdAttribute, RosettaXsdMapping xsdMapping) {
		Attribute attribute = SimpleFactory.eINSTANCE.createAttribute();

		// definition
		util.extractDocs(xsdAttribute).ifPresent(attribute::setDefinition);

		// name
		attribute.setName(util.allFirstLowerIfNotAbbrevation(xsdAttribute.getName()));
		
		// type call
		TypeCall typeCall = RosettaFactory.eINSTANCE.createTypeCall();
		attribute.setTypeCall(typeCall);

		// cardinality
		RosettaCardinality rosettaCardinality = RosettaFactory.eINSTANCE.createRosettaCardinality();
		if (xsdAttribute.getUse().equals(UsageEnum.REQUIRED.getValue())) {
			rosettaCardinality.setInf(1);
			rosettaCardinality.setSup(1);
		} else if (xsdAttribute.getUse().equals(UsageEnum.OPTIONAL.getValue())) {
			rosettaCardinality.setInf(0);
			rosettaCardinality.setSup(1);
		} else {
			throw new RuntimeException("Unknown XSD attribute usage: " + xsdAttribute.getUse());
		}
		attribute.setCard(rosettaCardinality);

		// docReference
//		RosettaBody body = typeMappings.getBody();
//		RosettaCorpus corpus = typeMappings.getCorpus();
//		RosettaSegment segment = typeMappings.getSegment();
//		Optional.ofNullable(xsdAttribute.getTypeAsSimpleType())
//			.map(xsdName -> createRosettaDocReference(xsdName.getName(), body, corpus, segment, util.extractDocs(xsdName)))
//			.ifPresent(attribute.getReferences()::add);
		
		xsdMapping.registerAttribute(xsdAttribute, attribute);
		
		return attribute;
	}
	private Attribute registerValueAttribute(XsdComplexType extendingType, RosettaXsdMapping xsdMapping) {
		Attribute attribute = SimpleFactory.eINSTANCE.createAttribute();

		// name
		attribute.setName(SIMPLE_EXTENSION_ATTRIBUTE_NAME);
		
		// type call
		TypeCall typeCall = RosettaFactory.eINSTANCE.createTypeCall();
		attribute.setTypeCall(typeCall);

		// cardinality
		RosettaCardinality rosettaCardinality = RosettaFactory.eINSTANCE.createRosettaCardinality();
		rosettaCardinality.setInf(1);
		rosettaCardinality.setSup(1);
		attribute.setCard(rosettaCardinality);

		// docReference
//		RosettaBody body = typeMappings.getBody();
//		RosettaCorpus corpus = typeMappings.getCorpus();
//		RosettaSegment segment = typeMappings.getSegment();
//		Optional.ofNullable(xsdAttribute.getTypeAsSimpleType())
//			.map(xsdName -> createRosettaDocReference(xsdName.getName(), body, corpus, segment, util.extractDocs(xsdName)))
//			.ifPresent(attribute.getReferences()::add);
		
		xsdMapping.registerAttribute(extendingType, attribute);
		
		return attribute;
	}
	
	private RosettaDocReference createRosettaDocReference(String xsdName, RosettaBody rosettaBody, RosettaCorpus rosettaCorpus, RosettaSegment rosettaSegment, Optional<String> provision) {
		RosettaDocReference rosettaDocReference = RosettaFactory.eINSTANCE.createRosettaDocReference();

		RegulatoryDocumentReference regulatoryDocumentReference = RosettaFactory.eINSTANCE.createRegulatoryDocumentReference();
		regulatoryDocumentReference.setBody(rosettaBody);
		regulatoryDocumentReference.getCorpuses().add(rosettaCorpus);
		rosettaDocReference.setDocReference(regulatoryDocumentReference);

		provision.ifPresent(rosettaDocReference::setProvision);

		RosettaSegmentRef rosettaSegmentRef = RosettaFactory.eINSTANCE.createRosettaSegmentRef();
		rosettaSegmentRef.setSegment(rosettaSegment);
		rosettaSegmentRef.setSegmentRef(xsdName);
		regulatoryDocumentReference.getSegments().add(rosettaSegmentRef);

		return rosettaDocReference;
	}
}
