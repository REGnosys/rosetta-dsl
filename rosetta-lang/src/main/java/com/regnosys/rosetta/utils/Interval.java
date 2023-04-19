package com.regnosys.rosetta.utils;

import java.util.Objects;
import java.util.Optional;

import org.apache.commons.lang3.Validate;

/**
 * A class representing an interval between two numbers.
 * 
 * The bounds are inclusive, an may be unbounded. The following forms are allowed:
 * - [min, max]
 * - ]-infinity, max]
 * - [min, +infinity[
 * - ]-infinity, +infinity[
 */
public class Interval<T extends Number & Comparable<T>> {
	private final Optional<T> min;
	private final Optional<T> max;
	
	public Interval(Optional<T> min, Optional<T> max) {
		if (min.isPresent() && max.isPresent()) {
			Validate.isTrue(min.get().compareTo(max.get()) <= 0);
		}
		this.min = min;
		this.max = max;
	}

	public static <U extends Number & Comparable<U>> Interval<U> bounded(U min, U max) {
		return new Interval<U>(Optional.of(min), Optional.of(max));
	}
	public static <U extends Number & Comparable<U>> Interval<U> boundedLeft(U max) {
		return new Interval<U>(Optional.empty(), Optional.of(max));
	}
	public static <U extends Number & Comparable<U>> Interval<U> boundedRight(U min) {
		return new Interval<U>(Optional.of(min), Optional.empty());
	}
	public static <U extends Number & Comparable<U>> Interval<U> unbounded() {
		return new Interval<U>(Optional.empty(), Optional.empty());
	}
	
	public Optional<T> getMin() {
		return this.min;
	}
	public Optional<T> getMax() {
		return this.max;
	}
	public boolean isUnbounded() {
		return min.isEmpty() && max.isEmpty();
	}
	
	public boolean includes(T x) {
		if (min.map(b -> b.compareTo(x) >= 0).orElse(false)) {
			return false;
		}
		if (max.map(b -> b.compareTo(x) <= 0).orElse(false)) {
			return false;
		}
		return true;
	}
	public boolean strictlyIncludes(T x) {
		if (min.map(b -> b.compareTo(x) > 0).orElse(false)) {
			return false;
		}
		if (max.map(b -> b.compareTo(x) < 0).orElse(false)) {
			return false;
		}
		return true;
	}
	
	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		min.ifPresentOrElse(
				b -> builder.append("[").append(b),
				() -> builder.append("]-inf"));
		builder.append(", ");
		max.ifPresentOrElse(
				b -> builder.append(b).append("]"),
				() -> builder.append("+inf["));
		return builder.toString();
	}
	@Override
	public int hashCode() {
		return Objects.hash(min, max);
	}
	@Override
	public boolean equals(Object object) {
		if (this == object) {
			return true;
		}
		if (getClass() != object.getClass()) {
			return false;
		}
		
		Interval<?> other = (Interval<?>)object;
		return Objects.equals(min, other.min)
				&& Objects.equals(max, other.max);
	}
}
