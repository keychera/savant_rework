package resavant.utils.daikon.diff;

public class ClassPair implements Comparable<ClassPair> {
	private Class<?> left = null, right = null;

	public Class<?> getLeft() {
		return left;
	}

	public Class<?> getRight() {
		return right;
	}

	public String toString() {
		return left.toString() + " " + right.toString();
	}

	@Override
	public int compareTo(ClassPair b) {

		return this.toString().compareTo(b.toString());
	}

	public ClassPair(Class<?> left, Class<?> right) {
		super();
		this.left = left;
		this.right = right;
	}

}
