package com.rosetta.model.lib.validation;

import com.rosetta.model.lib.path.RosettaPath;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.rosetta.model.lib.validation.ValidationResult.ValidationType.CHOICE_RULE;

public interface ValidationResult<T> {

	boolean isSuccess();

	@Deprecated
	String getModelObjectName();

	@Deprecated
	String getName();

	@Deprecated
	ValidationType getValidationType();
	@Deprecated
	String getDefinition();
	
	Optional<String> getFailureReason();
	
	RosettaPath getPath();

	Optional<ValidationData> getData();

	static <T> ValidationResult<T> success(String name, ValidationType validationType, String modelObjectName, RosettaPath path, String definition) {
		return new ModelValidationResult<>(name, validationType, modelObjectName, path, definition, Optional.empty(), Optional.empty());
	}
	
	static <T> ValidationResult<T> failure(String name, ValidationType validationType, String modelObjectName, RosettaPath path, String definition, String failureMessage) {
		return new ModelValidationResult<>(name, validationType, modelObjectName, path, definition, Optional.of(failureMessage), Optional.empty());
	}

	// @Compat: MODEL_INSTANCE is replaced by CARDINALITY, TYPE_FORMAT, KEY and can be removed in the future.
	enum ValidationType {
		DATA_RULE, CHOICE_RULE, MODEL_INSTANCE, CARDINALITY, TYPE_FORMAT, KEY, ONLY_EXISTS, PRE_PROCESS_EXCEPTION, POST_PROCESS_EXCEPTION
	}

	@Deprecated
	class ModelValidationResult<T> implements ValidationResult<T> {

		private final String modelObjectName;
		private final String name;
		private final String definition;
		private final Optional<String> failureReason;
		private final ValidationType validationType;
		private final RosettaPath path;
		private final Optional<ValidationData> data;

		public ModelValidationResult(String name, ValidationType validationType, String modelObjectName, RosettaPath path, String definition, Optional<String> failureReason, Optional<ValidationData> data) {
			this.name = name;
			this.validationType = validationType;
			this.path = path;
			this.modelObjectName = modelObjectName;
			this.definition = definition;
			this.failureReason = failureReason;
			this.data = data;
		}

		@Override
		public boolean isSuccess() {
			return !failureReason.isPresent();
		}

		@Override
		public String getModelObjectName() {
			return modelObjectName;
		}

		@Override
		public String getName() {
			return name;
		}
		
		public RosettaPath getPath() {
			return path;
		}

		@Override
		public Optional<ValidationData> getData() {
			return data;
		}

		@Override
		public String getDefinition() {
			return definition;
		}
		
		@Override
		public Optional<String> getFailureReason() {
			if (failureReason.isPresent() && modelObjectName.endsWith("Report") && ValidationType.DATA_RULE.equals(validationType)) {
				return getUpdatedFailureReason();
			}
			return failureReason;
		}

		@Override
		public ValidationType getValidationType() {
			return validationType;
		}

		@Override
		public String toString() {
			return String.format("Validation %s on [%s] for [%s] [%s] %s",
					isSuccess() ? "SUCCESS" : "FAILURE",
					path.buildPath(),
					validationType,
					name,
					failureReason.map(s -> "because [" + s + "]").orElse(""));
		}

		// TODO: refactor this method. This is an ugly hack.
		private Optional<String> getUpdatedFailureReason() {

			String conditionName = name.replaceFirst(modelObjectName, "");
			String failReason = failureReason.get();

			failReason = failReason.replaceAll(modelObjectName, "");
			failReason = failReason.replaceAll("->get", " ");
			failReason = failReason.replaceAll("[^\\w-]+", " ");
			failReason = failReason.replaceAll("^\\s+", "");

			return Optional.of(conditionName + ":- " + failReason);
		}
	}

	// @Compat. Choice rules are now obsolete in favor of data rules.
	@Deprecated
	class ChoiceRuleFailure<T> implements ValidationResult<T> {

		private final String name;
		private final String modelObjectName;
		private final List<String> populatedFields;
		private final List<String> choiceFieldNames;
		private final ChoiceRuleValidationMethod validationMethod;
		private final RosettaPath path;

		private final Optional<ValidationData> data;
		public ChoiceRuleFailure(String name, String modelObjectName, List<String> choiceFieldNames, RosettaPath path, List<String> populatedFields,
								 ChoiceRuleValidationMethod validationMethod, Optional<ValidationData> data) {
			this.name = name;
			this.path = path;
			this.modelObjectName = modelObjectName;
			this.populatedFields = populatedFields;
			this.choiceFieldNames = choiceFieldNames;
			this.validationMethod = validationMethod;
			this.data = data;
		}

		@Override
		public boolean isSuccess() {
			return false;
		}

		@Override
		public String getName() {
			return name;
		}
		
		public RosettaPath getPath() {
			return path;
		}
		@Override
		public Optional<ValidationData> getData() {
			return data;
		}
		@Override
		public String getModelObjectName() {
			return modelObjectName;
		}

		public List<String> populatedFields() {
			return populatedFields;
		}

		public List<String> choiceFieldNames() {
			return choiceFieldNames;
		}

		public ChoiceRuleValidationMethod validationMethod() {
			return validationMethod;
		}

		@Override
		public String getDefinition() {
			return choiceFieldNames().stream()
				.collect(Collectors.joining("', '", validationMethod().getDesc() + " of '", "'. "));
		}
		
		@Override
		public Optional<String> getFailureReason() {
			return Optional.of(getDefinition() + (populatedFields().isEmpty() ? "No fields are set." :
					populatedFields().stream().collect(Collectors.joining("', '", "Set fields are '", "'."))));
		}

		@Override
		public ValidationType getValidationType() {
			return CHOICE_RULE;
		}

		@Override
		public String toString() {
			return String.format("Validation %s on [%s] for [%s] [%s] %s",
					isSuccess() ? "SUCCESS" : "FAILURE",
					path.buildPath(),
					CHOICE_RULE + ":" + validationMethod,
					name,
					getFailureReason().map(reason -> "because " + reason).orElse(""));
		}
	}

}
