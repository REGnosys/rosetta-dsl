package com.regnosys.rosetta.validation;

public interface RosettaIssueCodes {
	
	static final String PREFIX = RosettaIssueCodes.class.getName() + ".";
	
	static final String DUPLICATE_ATTRIBUTE = PREFIX + "duplicateAttribute" ;
	static final String DUPLICATE_ENUM_VALUE = PREFIX + "duplicateEnumValue";
	static final String DUPLICATE_ELEMENT_NAME = PREFIX + "duplicateName" ;
	static final String INVALID_CASE = PREFIX + "invalidCase";
	static final String MISSING_ATTRIBUTE = PREFIX + "missingAttribute";
	static final String TYPE_ERROR = PREFIX + "typeError";
	static final String INVALID_TYPE = PREFIX + "InvalidType";
	static final String DUPLICATE_CHOICE_RULE_ATTRIBUTE = PREFIX + "DuplicateChoiceRuleAttribute";
	static final String CLASS_WITH_CHOICE_RULE_AND_ONE_OF_RULE = PREFIX + "ClassWithChoiceRuleAndOneOfRule";
	static final String MULIPLE_CLASS_REFERENCES_DEFINED_FOR_DATA_RULE = PREFIX + "MulipleClassReferencesDefinedForDataRule";
	static final String MAPPING_RULE_INVALID = PREFIX + "MappingRuleInvalid";
	static final String MAPPING_RULE_NOT_USED = PREFIX + "MappingRuleNotUsed";
	static final String MULIPLE_CLASS_REFERENCES_DEFINED_FOR_ROSETTA_QUALIFIABLE = PREFIX + "MulipleClassReferencesDefinedForRosettaQualifiable";
	static final String MISSING_ENUM_VALUE = PREFIX + "MissingEnumValue";
	static final String MISSING_BLUEPRINT_REGREF=PREFIX +"missingRegRef";
	static final String CARDINALITY_ERROR=PREFIX +"cardinalityError";
	static final String INVALID_ELEMENT_NAME=PREFIX +"invalidElementName";
}
