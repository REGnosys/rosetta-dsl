/*

 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.generator

import com.google.inject.Inject
import com.regnosys.rosetta.RosettaExtensions
import com.regnosys.rosetta.generator.external.ExternalGenerators
import com.regnosys.rosetta.generator.java.blueprints.BlueprintGenerator
import com.regnosys.rosetta.generator.java.enums.EnumGenerator
import com.regnosys.rosetta.generator.java.function.FuncGenerator
import com.regnosys.rosetta.generator.java.object.DataGenerator
import com.regnosys.rosetta.generator.java.object.DataValidatorsGenerator
import com.regnosys.rosetta.generator.java.object.JavaPackageInfoGenerator
import com.regnosys.rosetta.generator.java.object.MetaFieldGenerator
import com.regnosys.rosetta.generator.java.object.ModelMetaGenerator
import com.regnosys.rosetta.generator.java.object.ModelObjectGenerator
import com.regnosys.rosetta.generator.java.qualify.QualifyFunctionGenerator
import com.regnosys.rosetta.generator.java.rule.ChoiceRuleGenerator
import com.regnosys.rosetta.generator.java.rule.DataRuleGenerator
import com.regnosys.rosetta.generator.java.util.JavaNames
import com.regnosys.rosetta.generator.java.util.ModelNamespaceUtil
import com.regnosys.rosetta.generator.util.RosettaFunctionExtensions
import com.regnosys.rosetta.rosetta.RosettaEvent
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.RosettaProduct
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Function
import com.rosetta.util.DemandableLock
import java.util.concurrent.CancellationException
import org.apache.log4j.Level
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.lib.annotations.Delegate
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import com.regnosys.rosetta.generator.java.object.NamespaceHierarchyGenerator

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class RosettaGenerator extends AbstractGenerator {
	static Logger LOGGER = Logger.getLogger(RosettaGenerator) => [level = Level.DEBUG]

	@Inject ModelObjectGenerator modelObjectGenerator
	@Inject EnumGenerator enumGenerator
	@Inject ModelMetaGenerator metaGenerator
	@Inject ChoiceRuleGenerator choiceRuleGenerator
	@Inject DataRuleGenerator dataRuleGenerator
	@Inject BlueprintGenerator blueprintGenerator
	@Inject QualifyFunctionGenerator<RosettaEvent> qualifyEventsGenerator
	@Inject QualifyFunctionGenerator<RosettaProduct> qualifyProductsGenerator
	@Inject MetaFieldGenerator metaFieldGenerator
	@Inject ExternalGenerators externalGenerators
	@Inject JavaPackageInfoGenerator javaPackageInfoGenerator
	@Inject NamespaceHierarchyGenerator namespaceHierarchyGenerator

	@Inject DataGenerator dataGenerator
	@Inject DataValidatorsGenerator validatorsGenerator
	@Inject extension RosettaFunctionExtensions
	@Inject extension RosettaExtensions
	@Inject JavaNames.Factory factory
	@Inject FuncGenerator funcGenerator

	@Inject ModelNamespaceUtil modelNamespaceUtil

	// For files that are
	val ignoredFiles = #{'model-no-code-gen.rosetta'}

	val lock = new DemandableLock;

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa2, IGeneratorContext context) {
		LOGGER.debug("Starting the main generate method for " + resource.URI.toString)
		val fsa = new TestFolderAwareFsa(resource, fsa2)
		try {
			lock.getWriteLock(true);
			if (!ignoredFiles.contains(resource.URI.segments.last)) {
				// all models
				val models = if (resource.resourceSet?.resources === null) {
					LOGGER.warn("No resource set found for " + resource.URI.toString)
					newHashSet
				} else resource.resourceSet.resources.flatMap[contents].filter(RosettaModel).toSet

				// generate for each model object
				resource.contents.filter(RosettaModel).forEach [
					val version = version
					val javaNames = factory.create(it)
					val packages = javaNames.packages

					elements.forEach [
						if (context.cancelIndicator.canceled) {
							return // throw exception instead
						}
						switch (it) {
							Data: {
								dataGenerator.generate(javaNames, fsa, it, version)
								metaGenerator.generate(javaNames, fsa, it, version, models)
								validatorsGenerator.generate(javaNames, fsa, it, version)
								it.conditions.forEach [ cond |
									if (cond.isChoiceRuleCondition) {
										choiceRuleGenerator.generate(javaNames, fsa, it, cond, version)
									} else {
										dataRuleGenerator.generate(javaNames, fsa, it, cond, version)
									}
								]
							}
							Function: {
								if (!isDispatchingFunction) {
									funcGenerator.generate(javaNames, fsa, it, version)
								}
							}
						}
					]
					modelObjectGenerator.generate(javaNames, fsa, elements, version)
					enumGenerator.generate(packages, fsa, elements, version)
					choiceRuleGenerator.generate(packages, fsa, elements, version)
					dataRuleGenerator.generate(javaNames, fsa, elements, version)
					metaGenerator.generate(packages, fsa, elements, version)
					blueprintGenerator.generate(packages, fsa, elements, version)
					qualifyEventsGenerator.generate(packages, fsa, elements, packages.model.qualifyEvent, RosettaEvent,
						version)
					qualifyProductsGenerator.generate(packages, fsa, elements, packages.model.qualifyProduct,
						RosettaProduct, version)

					// Invoke externally defined code generators
					externalGenerators.forEach [ generator |
						generator.generate(packages, elements, version, [ map |
							map.entrySet.forEach[fsa.generateFile(key, generator.outputConfiguration.getName, value)]
						], resource, lock)
					]
				]

				val javaNames = factory.create(resource.contents.filter(RosettaModel).head)
				metaFieldGenerator.generate(javaNames.packages, resource, fsa, context)
			}
		} catch (CancellationException e) {
			LOGGER.trace("Code generation cancelled, this is expected")
		} catch (Exception e) {
			LOGGER.warn(
				"Unexpected calling standard generate for rosetta -" + e.message + " - see debug logging for more")
			LOGGER.info("Unexpected calling standard generate for rosetta", e);
		} finally {
			LOGGER.debug("ending the main generate method")
			lock.releaseWriteLock
		}
	}

	override void afterGenerate(Resource resource, IFileSystemAccess2 fsa2, IGeneratorContext context) {
		try {
			val fsa = new TestFolderAwareFsa(resource, fsa2)
		
			val models = resource.resourceSet.resources.flatMap[contents]
						.filter[!fsa.isTestResource(it.eResource)]
						.filter(RosettaModel).toList

			var namespaceDescriptionMap = modelNamespaceUtil.namespaceToDescriptionMap(models).asMap
			var namespaceUrilMap = modelNamespaceUtil.namespaceToModelUriMap(models).asMap
			
			javaPackageInfoGenerator.generatePackageInfoClasses(fsa, namespaceDescriptionMap)
			namespaceHierarchyGenerator.generateNamespacePackageHierarchy(fsa, namespaceDescriptionMap, namespaceUrilMap)

			externalGenerators.forEach [ generator |
				generator.afterGenerate(models, [ map |
					map.entrySet.forEach[fsa.generateFile(key, generator.outputConfiguration.getName, value)]
				], resource, lock)
			]

		} catch (Exception e) {
			LOGGER.warn("Unexpected calling after generate for rosetta -" + e.message + " - see debug logging for more")
			LOGGER.debug("Unexpected calling after generate for rosetta", e);
		}

	}
}

class TestFolderAwareFsa implements IFileSystemAccess2 {
	@Delegate IFileSystemAccess2 originalFsa
	boolean testRes

	new(Resource resource, IFileSystemAccess2 originalFsa) {
		this.originalFsa = originalFsa
		this.testRes = isTestResource(resource)
	}

	def boolean isTestResource(Resource resource) {
		if (resource.URI !== null) {
			// hardcode the folder for now
			return resource.getURI().toString.contains('src/test/resources/')
		}
		false
	}

	override void generateFile(String fileName, CharSequence contents) {
		if (testRes) {
			originalFsa.generateFile(fileName, RosettaOutputConfigurationProvider.SRC_TEST_GEN_JAVA_OUTPUT, contents)
		} else {
			originalFsa.generateFile(fileName, contents)
		}
	}
}
