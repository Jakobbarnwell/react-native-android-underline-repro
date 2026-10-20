import React, { useState } from 'react';
import { Button, ScrollView, StyleSheet, Text, View } from 'react-native';

export default function App() {
  const [inserted, setInserted] = useState(false);
  const [dimmed, setDimmed] = useState(false);

  return (
    <ScrollView style={styles.viewport} contentContainerStyle={styles.screen}>
      <Text style={styles.heading}>Android underline reproducer</Text>
      <Text style={styles.label}>A: nested, default font</Text>
      <Text style={[styles.line, { opacity: dimmed ? 0.99 : 1 }]}>
        Read the <Text style={styles.underline}>Terms of use</Text>.
      </Text>
      <Text style={styles.label}>B: standalone control</Text>
      <Text style={[styles.line, styles.underline]}>Terms of use</Text>
      <Text style={styles.label}>C: centered, wrapping, semibold</Text>
      <Text style={styles.wrapped}>
        By continuing, you agree to our{' '}
        <Text style={styles.underline}>Terms of use</Text> and confirm that you
        have read them.
      </Text>
      {inserted && Array.from({ length: 8 }, (_, index) => (
        <Text key={index}>Inserted sibling {index + 1}</Text>
      ))}
      <View style={styles.buttons}>
        <Button title="INSERT SIBLINGS" onPress={() => setInserted(!inserted)} />
        <Button title="REDRAW A (OPACITY)" onPress={() => setDimmed(!dimmed)} />
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  viewport: { flex: 1, backgroundColor: 'white' },
  screen: { paddingTop: 70, paddingHorizontal: 24 },
  heading: { fontSize: 20, marginBottom: 24, color: 'black' },
  label: { fontSize: 14, marginTop: 18, color: '#555' },
  line: { fontSize: 24, lineHeight: 36, color: 'black' },
  underline: { textDecorationLine: 'underline' },
  wrapped: { width: 250, textAlign: 'center', fontSize: 14, lineHeight: 20,
    fontWeight: '600', color: 'black' },
  buttons: { marginTop: 24, gap: 12 },
});
