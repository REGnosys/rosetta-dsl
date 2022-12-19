/*
 * generated by Xtext 2.24.0
 */
package com.regnosys.rosetta

import com.google.inject.Provider
import com.regnosys.rosetta.derivedstate.RosettaDerivedStateComputer
import com.regnosys.rosetta.generator.RosettaOutputConfigurationProvider
import com.regnosys.rosetta.generator.external.EmptyExternalGeneratorsProvider
import com.regnosys.rosetta.generator.external.ExternalGenerators
import com.regnosys.rosetta.generator.resourcefsa.ResourceAwareFSAFactory
import com.regnosys.rosetta.generator.resourcefsa.TestResourceAwareFSAFactory
import com.regnosys.rosetta.resource.RosettaFragmentProvider
import com.regnosys.rosetta.resource.RosettaResourceDescriptionManager
import com.regnosys.rosetta.resource.RosettaResourceDescriptionStrategy
import com.regnosys.rosetta.scoping.RosettaQualifiedNameProvider
import com.regnosys.rosetta.serialization.IgnoreDerivedStateSerializer
import org.eclipse.xtext.generator.IOutputConfigurationProvider
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.DerivedStateAwareResource
import org.eclipse.xtext.resource.IDerivedStateComputer
import org.eclipse.xtext.resource.IFragmentProvider
import org.eclipse.xtext.resource.IResourceDescription
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.impl.DefaultResourceDescriptionStrategy
import org.eclipse.xtext.serializer.ISerializer
import org.eclipse.xtext.parser.IEncodingProvider
import com.google.inject.Binder
import org.eclipse.xtext.service.DispatchingProvider
import com.regnosys.rosetta.utils.ImplicitVariableUtil
import org.eclipse.xsemantics.runtime.validation.XsemanticsValidatorFilter
import com.regnosys.rosetta.validation.RetainXsemanticsIssuesOnGeneratedInputsFilter
import org.eclipse.xtext.conversion.IValueConverterService
import com.regnosys.rosetta.parsing.RosettaValueConverterService
import com.regnosys.rosetta.parsing.BigDecimalConverter

/* Use this class to register components to be used at runtime / without the Equinox extension registry.*/
class RosettaRuntimeModule extends AbstractRosettaRuntimeModule {
	
	override Class<? extends IFragmentProvider> bindIFragmentProvider() {
		RosettaFragmentProvider
	}
	
	def Class<? extends ResourceAwareFSAFactory> bindResourceAwareFSAFactory() {
		TestResourceAwareFSAFactory
	}
	
	def Class<? extends DefaultResourceDescriptionStrategy> bindDefaultResourceDescriptionStrategy() {
		RosettaResourceDescriptionStrategy
	}
	
	override Class<? extends IQualifiedNameProvider> bindIQualifiedNameProvider() {
		return RosettaQualifiedNameProvider
	}
	
	def Class<? extends IOutputConfigurationProvider> bindIOutputConfigurationProvider() {
		return RosettaOutputConfigurationProvider
	}
	
	def Class<? extends IResourceDescription.Manager> bindIResourceDescriptionManager() {
		RosettaResourceDescriptionManager
	}
	
	def Class<? extends Provider<ExternalGenerators>> provideExternalGenerators() {
		EmptyExternalGeneratorsProvider
	}
	
	override Class<? extends ISerializer> bindISerializer() {
		IgnoreDerivedStateSerializer
	}
	
    override void configureRuntimeEncodingProvider(Binder binder) {
        binder.bind(IEncodingProvider)
        	.annotatedWith(DispatchingProvider.Runtime)
        	.to(UTF8EncodingProvider);
    }
    
    def Class<? extends ImplicitVariableUtil> bindImplicitVariableUtil() {
    	ImplicitVariableUtil
    }
    def Class<? extends XsemanticsValidatorFilter> bindXsemanticsValidatorFilter() {
    	RetainXsemanticsIssuesOnGeneratedInputsFilter
    }
    
    override Class<? extends IValueConverterService> bindIValueConverterService() {
    	RosettaValueConverterService
    }
    def Class<? extends BigDecimalConverter> bindBigDecimalConverter() {
    	BigDecimalConverter
    }
	
	override Class<? extends XtextResource> bindXtextResource() {
		return DerivedStateAwareResource
	}
	def Class<? extends IDerivedStateComputer> bindIDerivedStateComputer() {
		RosettaDerivedStateComputer
	}
}
