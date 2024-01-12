package com.rosetta.model.lib.meta;

import com.rosetta.model.lib.RosettaModelObject;
import com.rosetta.model.lib.RosettaModelObjectBuilder;
import com.rosetta.model.lib.annotations.RosettaAttribute;
import com.rosetta.model.lib.annotations.RosettaDataType;
import com.rosetta.model.lib.path.RosettaPath;
import com.rosetta.model.lib.process.BuilderMerger;
import com.rosetta.model.lib.process.BuilderProcessor;
import com.rosetta.model.lib.process.Processor;
import com.rosetta.model.lib.qualify.QualifyFunctionFactory;
import com.rosetta.model.lib.qualify.QualifyResult;
import com.rosetta.model.lib.validation.*;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.function.Function;

/**
 * @author TomForwood
 * This class represents a value that can be references elsewhere to link to the object the key is associated with
 * The keyValue is required to be unique within the scope defined by "scope"
 * 
 * Scope can be 
 *  - global - the key must be universally unique
 * 	- document - the key must be unique in this document
 *  - the name of the rosetta class e.g. TradeableProduct- the object bearing this key is inside a TradeableProduct and the key is only unique inside that TradeableProduct
 */
@RosettaDataType(value = "Key", builder = Key.KeyBuilderImpl.class)
public interface Key extends RosettaModelObject{

	public String getScope();
	public String getKeyValue();
	
	Key build();
	KeyBuilder toBuilder();
	
	final static KeyMeta meta = new KeyMeta();
	@Override
	default RosettaMetaData<? extends RosettaModelObject> metaData() {
		return meta;
	}
	
	default Class<? extends RosettaModelObject> getType() {
		return Key.class;
	}
	
	default void process(RosettaPath path, Processor processor) {
	}
	
	static KeyBuilder builder() {
		return new KeyBuilderImpl();
	}
	
	interface KeyBuilder extends Key, RosettaModelObjectBuilder {
		KeyBuilder setScope(String scope);
		KeyBuilder setKeyValue(String keyValue);
		
		default void process(RosettaPath path, BuilderProcessor processor) {
		}
	}
	
	class KeyImpl implements Key {
		
		private final String scope;
		private final String keyValue;
		public KeyImpl(KeyBuilder builder) {
			super();
			this.scope = builder.getScope();
			this.keyValue = builder.getKeyValue();
		}
		
		@RosettaAttribute("scope")
		public String getScope() {
			return scope;
		}
		
		@RosettaAttribute("value")
		public String getKeyValue() {
			return keyValue;
		}
	
		public KeyBuilder toBuilder() {
			KeyBuilder key = builder();
			key.setKeyValue(keyValue);
			key.setScope(scope);
			return key;
		}
		
		public Key build() {
			return this;
		}
		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + ((keyValue == null) ? 0 : keyValue.hashCode());
			result = prime * result + ((scope == null) ? 0 : scope.hashCode());
			return result;
		}
		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			KeyImpl other = (KeyImpl) obj;
			if (keyValue == null) {
				if (other.keyValue != null)
					return false;
			} else if (!keyValue.equals(other.keyValue))
				return false;
			if (scope == null) {
				if (other.scope != null)
					return false;
			} else if (!scope.equals(other.scope))
				return false;
			return true;
		}
	}
	
	public static class KeyBuilderImpl implements KeyBuilder{
		private String scope;
		private String keyValue;
		
		public Key build() {
			return new KeyImpl(this);
		}

		@RosettaAttribute("scope")
		public String getScope() {
			return scope;
		}

		@RosettaAttribute("scope")
		public KeyBuilder setScope(String scope) {
			this.scope = scope;
			return this;
		}

		@RosettaAttribute("value")
		public String getKeyValue() {
			return keyValue;
		}

		@RosettaAttribute("value")
		public KeyBuilder setKeyValue(String keyValue) {
			this.keyValue = keyValue;
			return this;
		}
		
		public boolean hasData() {
			return keyValue!=null;
		}

		@Override
		public KeyBuilder toBuilder() {
			return this;
		}

		@SuppressWarnings("unchecked")
		@Override
		public KeyBuilder prune() {
			return this;
		}

		@SuppressWarnings("unchecked")
		@Override
		public KeyBuilder merge(RosettaModelObjectBuilder other, BuilderMerger merger) {
			KeyBuilder otherKey = (KeyBuilder) other;
			merger.mergeBasic(getKeyValue(), otherKey.getKeyValue(), this::setKeyValue);
			merger.mergeBasic(getScope(), otherKey.getScope(), this::setScope);
			return this;
		}

		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + ((keyValue == null) ? 0 : keyValue.hashCode());
			result = prime * result + ((scope == null) ? 0 : scope.hashCode());
			return result;
		}

		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			KeyBuilderImpl other = (KeyBuilderImpl) obj;
			if (keyValue == null) {
				if (other.keyValue != null)
					return false;
			} else if (!keyValue.equals(other.keyValue))
				return false;
			if (scope == null) {
				if (other.scope != null)
					return false;
			} else if (!scope.equals(other.scope))
				return false;
			return true;
		}
	}
	
	class KeyMeta implements RosettaMetaData<Key> {


		@Override
		public List<Validator<? super Key>> dataRules(ValidatorFactory factory) {
			return Collections.emptyList();
		}

		@Override
		public List<Validator<? super Key>> choiceRuleValidators() {
			return Collections.emptyList();
		}

		@Override
		public List<Function<? super Key, QualifyResult>> getQualifyFunctions(QualifyFunctionFactory factory) {
			return Collections.emptyList();
		}

		@Override
		public Validator<? super Key> validator() {
			return new Validator<Key>() {

				@Override
				public ValidationResult validate(RosettaPath path, Key key) {
					if (key.getKeyValue()==null) {
						return ValidationResult.failure(path, "Key value must be set", new ValidationData());
					}
					if (key.getScope()==null) {
						return ValidationResult.failure(path, "Key scope must be set", new ValidationData());
					}
					return ValidationResult.success(path);
				}
			};
		}
		
		@Override
		public Validator<? super Key> typeFormatValidator() {
			return null;
		}

		@Override
		public ValidatorWithArg<? super Key, Set<String>> onlyExistsValidator() {
			return null;
		}
	}
}
