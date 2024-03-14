package com.rosetta.model.metafields;

import com.rosetta.model.lib.RosettaModelObject;
import com.rosetta.model.lib.RosettaModelObjectBuilder;
import com.rosetta.model.lib.annotations.RosettaAttribute;
import com.rosetta.model.lib.annotations.RosettaDataType;
import com.rosetta.model.lib.meta.BasicRosettaMetaData;
import com.rosetta.model.lib.meta.Reference;
import com.rosetta.model.lib.meta.ReferenceWithMeta;
import com.rosetta.model.lib.meta.ReferenceWithMeta.ReferenceWithMetaBuilder;
import com.rosetta.model.lib.meta.RosettaMetaData;
import com.rosetta.model.lib.path.RosettaPath;
import com.rosetta.model.lib.process.AttributeMeta;
import com.rosetta.model.lib.process.BuilderMerger;
import com.rosetta.model.lib.process.BuilderProcessor;
import com.rosetta.model.lib.process.Processor;
import java.math.BigInteger;
import java.util.Objects;

import static java.util.Optional.ofNullable;

/**
 * @version 1
 */
@RosettaDataType(value="ReferenceWithMetaBigInteger", builder=ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilderImpl.class, version="0.0.0")
public interface ReferenceWithMetaBigInteger extends RosettaModelObject, ReferenceWithMeta<BigInteger> {

	ReferenceWithMetaBigIntegerMeta metaData = new ReferenceWithMetaBigIntegerMeta();

	/*********************** Getter Methods  ***********************/
	BigInteger getValue();
	String getGlobalReference();
	String getExternalReference();
	Reference getReference();

	/*********************** Build Methods  ***********************/
	ReferenceWithMetaBigInteger build();
	
	ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder toBuilder();
	
	static ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder builder() {
		return new ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilderImpl();
	}

	/*********************** Utility Methods  ***********************/
	@Override
	default RosettaMetaData<? extends ReferenceWithMetaBigInteger> metaData() {
		return metaData;
	}
	
	@Override
	default Class<? extends ReferenceWithMetaBigInteger> getType() {
		return ReferenceWithMetaBigInteger.class;
	}
	
	@Override
	default Class<BigInteger> getValueType() {
		return BigInteger.class;
	}
	
	@Override
	default void process(RosettaPath path, Processor processor) {
		processor.processBasic(path.newSubPath("value"), BigInteger.class, getValue(), this);
		processor.processBasic(path.newSubPath("globalReference"), String.class, getGlobalReference(), this, AttributeMeta.META);
		processor.processBasic(path.newSubPath("externalReference"), String.class, getExternalReference(), this, AttributeMeta.META);
		processRosetta(path.newSubPath("reference"), processor, Reference.class, getReference());
	}
	

	/*********************** Builder Interface  ***********************/
	interface ReferenceWithMetaBigIntegerBuilder extends ReferenceWithMetaBigInteger, RosettaModelObjectBuilder, ReferenceWithMeta.ReferenceWithMetaBuilder<BigInteger> {
		Reference.ReferenceBuilder getOrCreateReference();
		Reference.ReferenceBuilder getReference();
		ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setValue(BigInteger value);
		ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setGlobalReference(String globalReference);
		ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setExternalReference(String externalReference);
		ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setReference(Reference reference);

		@Override
		default void process(RosettaPath path, BuilderProcessor processor) {
			processor.processBasic(path.newSubPath("value"), BigInteger.class, getValue(), this);
			processor.processBasic(path.newSubPath("globalReference"), String.class, getGlobalReference(), this, AttributeMeta.META);
			processor.processBasic(path.newSubPath("externalReference"), String.class, getExternalReference(), this, AttributeMeta.META);
			processRosetta(path.newSubPath("reference"), processor, Reference.ReferenceBuilder.class, getReference());
		}
		

		ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder prune();
	}

	/*********************** Immutable Implementation of ReferenceWithMetaBigInteger  ***********************/
	class ReferenceWithMetaBigIntegerImpl implements ReferenceWithMetaBigInteger {
		private final BigInteger value;
		private final String globalReference;
		private final String externalReference;
		private final Reference reference;
		
		protected ReferenceWithMetaBigIntegerImpl(ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder builder) {
			this.value = builder.getValue();
			this.globalReference = builder.getGlobalReference();
			this.externalReference = builder.getExternalReference();
			this.reference = ofNullable(builder.getReference()).map(f->f.build()).orElse(null);
		}
		
		@Override
		@RosettaAttribute("value")
		public BigInteger getValue() {
			return value;
		}
		
		@Override
		@RosettaAttribute("globalReference")
		public String getGlobalReference() {
			return globalReference;
		}
		
		@Override
		@RosettaAttribute("externalReference")
		public String getExternalReference() {
			return externalReference;
		}
		
		@Override
		@RosettaAttribute("address")
		public Reference getReference() {
			return reference;
		}
		
		@Override
		public ReferenceWithMetaBigInteger build() {
			return this;
		}
		
		@Override
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder toBuilder() {
			ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder builder = builder();
			setBuilderFields(builder);
			return builder;
		}
		
		protected void setBuilderFields(ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder builder) {
			ofNullable(getValue()).ifPresent(builder::setValue);
			ofNullable(getGlobalReference()).ifPresent(builder::setGlobalReference);
			ofNullable(getExternalReference()).ifPresent(builder::setExternalReference);
			ofNullable(getReference()).ifPresent(builder::setReference);
		}

		@Override
		public boolean equals(Object o) {
			if (this == o) return true;
			if (o == null || !(o instanceof RosettaModelObject) || !getType().equals(((RosettaModelObject)o).getType())) return false;
		
			ReferenceWithMetaBigInteger _that = getType().cast(o);
		
			if (!Objects.equals(value, _that.getValue())) return false;
			if (!Objects.equals(globalReference, _that.getGlobalReference())) return false;
			if (!Objects.equals(externalReference, _that.getExternalReference())) return false;
			if (!Objects.equals(reference, _that.getReference())) return false;
			return true;
		}
		
		@Override
		public int hashCode() {
			int _result = 0;
			_result = 31 * _result + (value != null ? value.hashCode() : 0);
			_result = 31 * _result + (globalReference != null ? globalReference.hashCode() : 0);
			_result = 31 * _result + (externalReference != null ? externalReference.hashCode() : 0);
			_result = 31 * _result + (reference != null ? reference.hashCode() : 0);
			return _result;
		}
		
		@Override
		public String toString() {
			return "ReferenceWithMetaBigInteger {" +
				"value=" + this.value + ", " +
				"globalReference=" + this.globalReference + ", " +
				"externalReference=" + this.externalReference + ", " +
				"reference=" + this.reference +
			'}';
		}
	}

	/*********************** Builder Implementation of ReferenceWithMetaBigInteger  ***********************/
	class ReferenceWithMetaBigIntegerBuilderImpl implements ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder {
	
		protected BigInteger value;
		protected String globalReference;
		protected String externalReference;
		protected Reference.ReferenceBuilder reference;
	
		public ReferenceWithMetaBigIntegerBuilderImpl() {
		}
	
		@Override
		@RosettaAttribute("value")
		public BigInteger getValue() {
			return value;
		}
		
		@Override
		@RosettaAttribute("globalReference")
		public String getGlobalReference() {
			return globalReference;
		}
		
		@Override
		@RosettaAttribute("externalReference")
		public String getExternalReference() {
			return externalReference;
		}
		
		@Override
		@RosettaAttribute("address")
		public Reference.ReferenceBuilder getReference() {
			return reference;
		}
		
		@Override
		public Reference.ReferenceBuilder getOrCreateReference() {
			Reference.ReferenceBuilder result;
			if (reference!=null) {
				result = reference;
			}
			else {
				result = reference = Reference.builder();
			}
			
			return result;
		}
	
		@Override
		@RosettaAttribute("value")
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setValue(BigInteger value) {
			this.value = value==null?null:value;
			return this;
		}
		@Override
		@RosettaAttribute("globalReference")
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setGlobalReference(String globalReference) {
			this.globalReference = globalReference==null?null:globalReference;
			return this;
		}
		@Override
		@RosettaAttribute("externalReference")
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setExternalReference(String externalReference) {
			this.externalReference = externalReference==null?null:externalReference;
			return this;
		}
		@Override
		@RosettaAttribute("address")
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder setReference(Reference reference) {
			this.reference = reference==null?null:reference.toBuilder();
			return this;
		}
		
		@Override
		public ReferenceWithMetaBigInteger build() {
			return new ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerImpl(this);
		}
		
		@Override
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder toBuilder() {
			return this;
		}
	
		@SuppressWarnings("unchecked")
		@Override
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder prune() {
			if (reference!=null && !reference.prune().hasData()) reference = null;
			return this;
		}
		
		@Override
		public boolean hasData() {
			if (getValue()!=null) return true;
			if (getGlobalReference()!=null) return true;
			if (getExternalReference()!=null) return true;
			if (getReference()!=null && getReference().hasData()) return true;
			return false;
		}
	
		@SuppressWarnings("unchecked")
		@Override
		public ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder merge(RosettaModelObjectBuilder other, BuilderMerger merger) {
			ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder o = (ReferenceWithMetaBigInteger.ReferenceWithMetaBigIntegerBuilder) other;
			
			merger.mergeRosetta(getReference(), o.getReference(), this::setReference);
			
			merger.mergeBasic(getValue(), o.getValue(), this::setValue);
			merger.mergeBasic(getGlobalReference(), o.getGlobalReference(), this::setGlobalReference);
			merger.mergeBasic(getExternalReference(), o.getExternalReference(), this::setExternalReference);
			return this;
		}
	
		@Override
		public boolean equals(Object o) {
			if (this == o) return true;
			if (o == null || !(o instanceof RosettaModelObject) || !getType().equals(((RosettaModelObject)o).getType())) return false;
		
			ReferenceWithMetaBigInteger _that = getType().cast(o);
		
			if (!Objects.equals(value, _that.getValue())) return false;
			if (!Objects.equals(globalReference, _that.getGlobalReference())) return false;
			if (!Objects.equals(externalReference, _that.getExternalReference())) return false;
			if (!Objects.equals(reference, _that.getReference())) return false;
			return true;
		}
		
		@Override
		public int hashCode() {
			int _result = 0;
			_result = 31 * _result + (value != null ? value.hashCode() : 0);
			_result = 31 * _result + (globalReference != null ? globalReference.hashCode() : 0);
			_result = 31 * _result + (externalReference != null ? externalReference.hashCode() : 0);
			_result = 31 * _result + (reference != null ? reference.hashCode() : 0);
			return _result;
		}
		
		@Override
		public String toString() {
			return "ReferenceWithMetaBigIntegerBuilder {" +
				"value=" + this.value + ", " +
				"globalReference=" + this.globalReference + ", " +
				"externalReference=" + this.externalReference + ", " +
				"reference=" + this.reference +
			'}';
		}
	}
}

class ReferenceWithMetaBigIntegerMeta extends BasicRosettaMetaData<ReferenceWithMetaBigInteger>{

}
